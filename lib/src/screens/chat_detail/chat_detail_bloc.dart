import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/models/message_model.dart';
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

final class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final dynamic chatOrUser;
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  StreamSubscription? _getMessagesSubscription;
  StreamSubscription? _getChatSubscription;

  ChatDetailBloc(this.chatOrUser) : super(ChatDetailState.initial()) {
    on<ChatDetailInitializedEvent>((event, emit) =>
      _onInitialized(event, emit, chatOrUser)
    );
    on<ChatDetailUpdatedEvent>(_onUpdated);
    on<ChatDetailMessagesUpdatedEvent>(_onMessagesUpdated);
    on<ChatDetailMessagesFetchedEvent>(_onMessagesFetched);
    on<ChatDetailTextChangedEvent>(_onTextChanged);
    on<ChatDetailSendTextEvent>(_onSendText);
    on<ChatDetailSendImageFromCameraEvent>((event, emit) =>
      _onSendImage(event, emit, ImageSource.camera)
    );
    on<ChaDetailtSendImageFromLibraryEvent>((event, emit) =>
      _onSendImage(event, emit, ImageSource.gallery)
    );
  }

  @override
  Future<void> close() async {
    scrollController.dispose();
    textController.dispose();
    await _getMessagesSubscription?.cancel();
    await _getChatSubscription?.cancel();
    return super.close();
  }

  void _onInitialized(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit,
    dynamic newChatOrUser
  ) async {
    if (newChatOrUser is Chat) {
      emit(state.copyWith(
        chat: newChatOrUser
      ));
      _getMessagesSubscription = ChatService.watchMessages(newChatOrUser.id)
        .listen((newMessages) async {
          add(ChatDetailUpdatedEvent(
            await ChatService.updateLastVisitTimestamp(
              (state.chat != null) ? state.chat! : newChatOrUser
            )
          ));
          add(ChatDetailMessagesUpdatedEvent(newMessages));
        });
      _getChatSubscription = ChatService.watchChat(newChatOrUser.id)
        .listen((newChat) {
          add(ChatDetailUpdatedEvent(newChat));
        });
    } else if (newChatOrUser is User) {
      emit(state.copyWith(
        user: newChatOrUser
      ));
    }
  }

  void _onUpdated(
    ChatDetailUpdatedEvent event,
    Emitter<ChatDetailState> emit
  ) {
    emit(state.copyWith(
      chat: event.chat
    ));
  }

  void _onMessagesUpdated(
    ChatDetailMessagesUpdatedEvent event,
    Emitter<ChatDetailState> emit
  ) async {
    emit(state.copyWith(
      messages: event.messages
    ));
    await Future.delayed(const Duration(milliseconds: 300));
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void _onMessagesFetched(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit
  ) async {
    if (state.chat != null && state.messages.last.docSnapshot != null) {
      List<Message> newMessages = await ChatService.fetchMessages(
        state.chat!.id,
        state.messages.last.docSnapshot!
      );
      emit(state.copyWith(
        messages: state.messages + newMessages
      ));
    }
  }

  void _onTextChanged(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit
  ) {
    emit(state.copyWith(
      isTextValid: textController.text.isNotEmpty
    ));
  }

  void _onSendText(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit
  ) async {
    String text = textController.text;
    textController.text = '';
    _onTextChanged(event, emit);
    await ChatService.sendTextMessage(
      await _getChatId(event, emit), text
    );
  }

  void _onsendaudio (
      ChatDetailEvent event,
      Emitter<ChatDetailState> emit
      ) async{

  }

  void _onSendImage(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit,
    ImageSource imageSource
  ) async {
    try {
      XFile? pickedImage = await ImagePicker().pickImage(
        source: imageSource,
        maxWidth: 400
      );
      if (pickedImage != null) {
        emit(state.copyWith(
          isLoading: true
        ));
        await ChatService.sendImageMessage(
          await _getChatId(event, emit),
          File(pickedImage.path)
        );
      }
    } finally {
      emit(state.copyWith(
        isLoading: false
      ));
    }
  }

  Future<String> _getChatId(
    ChatDetailEvent event,
    Emitter<ChatDetailState> emit
  ) async {
    if (state.chat == null) {
      Chat newChat = await ChatService.createChat(state.user!.id);
      _onInitialized(event, emit, newChat);
      return newChat.id;
    } else {
      return state.chat!.id;
    }
  }
}