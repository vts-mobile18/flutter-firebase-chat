import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/models/message_model.dart';
import 'storage_service.dart';
import 'auth_service.dart';

abstract final class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _pageLimitCount = 15;

  static Stream<List<Chat>> watchChats() {
    Query chatsQuery = _firestore
      .collection('chats')
      .where('userIds', arrayContains: AuthService.fetchCurrentUserId());
    return chatsQuery.snapshots().map<QuerySnapshot>((el) => el).transform(
      StreamTransformer<QuerySnapshot, List<Chat>>
        .fromHandlers(handleData: (chatsSnapshot, sink) async {
          sink.add(await _fetchChatsByDocs(chatsSnapshot.docs));
        })
    );
  }

  static Future<List<Chat>> fetchChats() async {
    QuerySnapshot chatsSnapshot = await _firestore
      .collection('chats')
      .where('userIds', arrayContains: AuthService.fetchCurrentUserId())
      .get();
    return _fetchChatsByDocs(chatsSnapshot.docs);
  }

  static Future<(List<Chat>, List<User>)> fetchChatsAndUsersByQuery(String query) async {
    List<User> users = await _fetchUsersByQuery(query);
    List<Chat> chats = await _fetchChatsByUserIds(
      users.map((user) => user.id).toList()
    );
    users = users.where((user) =>
      chats.indexWhere((chat) =>
        (chat.members.length == 2) && chat.members.containsKey(user.id)
      ) == -1
    ).toList();
    return (chats, users);
  }

  static Future<List<User>> fetchUsersByQueryExceptMembers(
    String query,
    Map members
  ) async {
    List<User> users = await _fetchUsersByQuery(query);
    return users.where((user) =>
      !members.containsKey(user.id)
    ).toList();
  }

  static Stream<Chat> watchChat(String chatId) {
    DocumentReference chatRef = _firestore
      .collection('chats')
      .doc(chatId);
    return chatRef.snapshots().map<DocumentSnapshot>((el) => el).transform(
      StreamTransformer<DocumentSnapshot, Chat>
        .fromHandlers(handleData: (chatDoc, sink) async {
          sink.add(await _fetchChatByDoc(chatDoc));
        })
    );
  }

  static Future<Chat> createChat(String userId) async {
    List<String> userIds = [
      AuthService.fetchCurrentUserId(), userId
    ];
    Map members = await _createChatMembers(userIds);
    return _fetchChatByDoc(
      await (
        await _firestore.collection('chats').add({
          'members': members,
          'userIds': userIds
        })
      ).get()
    );
  }

  static Future removeChat(String chatId) async {
    DocumentReference chatDocRef = _firestore
      .collection('chats')
      .doc(chatId);
    QuerySnapshot messagesSnapshot = await chatDocRef
      .collection('messages')
      .get();
    await Future.wait(messagesSnapshot.docs.map((messageDoc) =>
      messageDoc.reference.delete()
    ));
    return chatDocRef.delete();
  }

  static Future<void> addChatMember(
    Chat chat,
    String userId
  ) {
    return _updateChatMembers(chat.members, chat.id, userId);
  }

  static Future<Chat> updateLastVisitTimestamp(Chat chat) async {
    chat.members[AuthService.fetchCurrentUserId()]['lastVisitTimestamp'] = DateTime.now();
    await _updateChatMembers(chat.members, chat.id);
    return chat;
  }

  static Stream<List<Message>> watchMessages(String chatId) {
    Query messagesQuery = _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('date', descending: true)
      .limit(_pageLimitCount + 1);
    return messagesQuery.snapshots().map<QuerySnapshot>((el) => el).transform(
      StreamTransformer<QuerySnapshot, List<Message>>
        .fromHandlers(handleData: (messagesSnapshot, sink) {
          sink.add(_fetchMessagesByDocs(messagesSnapshot.docs));
        })
    );
  }

  static Future<List<Message>> fetchMessages(
    String chatId,
    DocumentSnapshot docSnapshot
  ) async {
    QuerySnapshot messagesSnapshot = await _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('date', descending: true)
      .startAfterDocument(docSnapshot)
      .limit(_pageLimitCount + 1)
      .get();
    return _fetchMessagesByDocs(messagesSnapshot.docs);
  }

  static Future<DocumentReference> sendTextMessage(
    String chatId,
    String message
  ) {
    return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
        'content': message,
        'contentType': 'text',
        'date': DateTime.now(),
        'userId': AuthService.fetchCurrentUserId()
      });
  }

  static Future<DocumentReference> sendImageMessage(
    String chatId,
    File imageFile
  ) async {
    return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
        'content': await StorageService.saveFile(
          imageFile,
          'messages/$chatId${DateTime.now().millisecondsSinceEpoch}.jpg'
        ),
        'contentType': 'image',
        'date': DateTime.now(),
        'userId': AuthService.fetchCurrentUserId()
      });
  }

  static Future<List<Chat>> _fetchChatsByUserIds(List<String> userIds) async {
    List<List<Chat>> chats = await Future.wait(userIds.map((userId) async {
      QuerySnapshot chatsSnapshot = await _firestore
        .collection('chats')
        .where('userIds', arrayContains: userId)
        .get();
      return _fetchChatsByDocs(chatsSnapshot.docs);
    }));
    return chats.fold<List<Chat>>([], (prevChats, currentChats) {
      for (Chat currentChat in currentChats) {
        int prevIndex = prevChats.indexWhere((prevChat) => prevChat.id == currentChat.id);
        if (prevIndex == -1) {
          prevChats.add(currentChat);
        }
      }
      return prevChats;
    });
  }

  static Future<List<Chat>> _fetchChatsByDocs(
    List<DocumentSnapshot> chatDocs
  ) async {
    if (chatDocs.isEmpty) {
      return [];
    }
    return Future.wait(chatDocs.map((chatDoc) =>
      _fetchChatByDoc(chatDoc)
    ));
  }

  static Future<Chat> _fetchChatByDoc(
    DocumentSnapshot chatDoc
  ) async {
    String currentUserId = AuthService.fetchCurrentUserId();
    QuerySnapshot messagesSnapshot = await _firestore
      .collection('chats')
      .doc(chatDoc.id)
      .collection('messages')
      .orderBy('date', descending: true)
      .limit(1)
      .get();
    List<DocumentSnapshot> messageDocs = messagesSnapshot.docs;
    Map? messageData = messageDocs.isNotEmpty ?
      messageDocs[0].data() as Map :
      null;
    List<String> imageUrls = [];
    Map members = (chatDoc.data() as Map)['members'];
    members.forEach((key, value) {
      if (key != currentUserId) {
        imageUrls.add(value['imageUrl']);
      }
    });
    return Chat(
      id: chatDoc.id,
      imageUrls: imageUrls,
      name: _chatNameByMembers(members),
      text: (messageData != null) ?
        (messageData['contentType'] == 'text') ?
          messageData['content'] :
          messageData['contentType'] :
        '',
      date: timeago.format(
        (messageData != null) ?
          messageData['date'].toDate() :
          DateTime.now()
      ),
      hasUnreadMessages: (messageData == null) ||
        (messageData['userId'] != currentUserId) &&
        (messageData['date'].toDate().isAfter(members[currentUserId]['lastVisitTimestamp'].toDate())),
      members: members
    );
  }

  static Future<List<User>> _fetchUsersByQuery(String query) async {
    Query usersQuery = _firestore.collection('users');
    if (query.isNotEmpty) {
      usersQuery = usersQuery.where('searchTerms', arrayContains: query.toLowerCase());
    }
    List<DocumentSnapshot> userDocs = (await usersQuery.get()).docs;
    String currentUserId = AuthService.fetchCurrentUserId();
    return userDocs.map((userDoc) {
      Map userData = userDoc.data() as Map;
      return User(
        id: userDoc.id,
        imageUrl: userData['imageUrl'],
        name: userData['username']
      );
    }).toList().where((user) =>
      user.id != currentUserId
    ).toList();
  }

  static Future<void> _updateChatMembers(
    Map oldMembers,
    String chatId,
    [String? newUserId]
  ) async {
    if (newUserId != null) {
      DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(newUserId)
        .get();
      Map userData = userDoc.data() as Map;
      oldMembers[newUserId] = {
        'username': userData['username'],
        'imageUrl': userData['imageUrl'],
        'lastVisitTimestamp': DateTime.now()
      };
    }
    return _firestore
      .collection('chats')
      .doc(chatId)
      .update({
        'members': oldMembers,
        'userIds': oldMembers.keys.toList()
      });
  }

  static Future<Map> _createChatMembers(
    List<String> userIds
  ) async {
    List<DocumentSnapshot> userDocs = await Future.wait(userIds.map((userId) =>
      _firestore.collection('users').doc(userId).get()
    ));
    Map members = {};
    DateTime nowDate = DateTime.now();
    userDocs.asMap().forEach((userDocIndex, userDoc) {
      Map userData = userDoc.data() as Map;
      members[userIds[userDocIndex]] = {
        'username': userData['username'],
        'imageUrl': userData['imageUrl'],
        'lastVisitTimestamp': nowDate
      };
    });
    return members;
  }

  static String _chatNameByMembers(Map members) {
    String currentUserId = AuthService.fetchCurrentUserId();
    List<String> membersNames = [];
    members.forEach((key, value) {
      if (key != currentUserId) {
        membersNames.add(value['username']);
      }
    });
    late String chatName;
    if (membersNames.length > 1) {
      chatName = membersNames.sublist(0, 2).join(', ');
    }
    else {
      chatName = membersNames.join(', ');
    }
    if (membersNames.length > 2) {
      chatName += ' and ${membersNames.length - 2} other(s)';
    }
    return chatName;
  }

  static List<Message> _fetchMessagesByDocs(
    List<DocumentSnapshot> messageDocs
  ) {
    if (messageDocs.isEmpty) {
      return [];
    }
    bool isLastPage = messageDocs.length < (_pageLimitCount + 1);
    if (messageDocs.length > _pageLimitCount) {
      messageDocs = messageDocs.sublist(0, _pageLimitCount);
    }
    String currentUserId = AuthService.fetchCurrentUserId();
    List<Message> messages = messageDocs.map((messageDoc) =>
      Message.fromDoc(messageDoc, currentUserId)
    ).toList();
    if (isLastPage) {
      messages.last.docSnapshot = null;
    }
    return messages;
  }
}