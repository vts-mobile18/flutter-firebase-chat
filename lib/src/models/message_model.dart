import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

final class Message {
  final String content;
  final String contentType;
  final String date;
  final String? userId;
  DocumentSnapshot? docSnapshot;

  Message({
    required this.content,
    required this.contentType,
    required this.date,
    required this.userId,
    required this.docSnapshot
  });

  factory Message.fromDoc(
    DocumentSnapshot messageDoc,
    String currentUserId
  ) {
    Map messageData = messageDoc.data() as Map;
    return Message(
      content: messageData['content'],
      contentType:  messageData['contentType'],
      date: timeago.format(messageData['date'].toDate()),
      userId: (currentUserId != messageData['userId']) ? messageData['userId'] : null,
      docSnapshot: messageDoc
    );
  }
}