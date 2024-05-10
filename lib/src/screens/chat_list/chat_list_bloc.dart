import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
part 'chat_list_event.dart';
part 'chat_list_state.dart';

final class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final TextEditingController searchBarController = TextEditingController();
  StreamSubscription? _getChatsSubscription;

  ChatListBloc() : super(ChatListState.initial()) {
    on<ChatListInitializedEvent>(_onInitialized);
    on<ChatListSearchBarShownEvent>(_onSearchbarShown);
    on<ChatListSearchBarChangedEvent>(_onSearchbarChanged);
    on<ChatListItemsChangedEvent>(_onItemsChanged);
    on<ChatListItemRemovedEvent>(_onItemRemoved);
  }

  @override
  Future<void> close() async {
    searchBarController.dispose();
    await _getChatsSubscription?.cancel();
    return super.close();
  }

  void _onInitialized(
    ChatListEvent event,
    Emitter<ChatListState> emit
  ) {
    _getChatsSubscription = ChatService.watchChats()
      .listen((newChats) {
        if (searchBarController.text.isEmpty) {
          add(ChatListItemsChangedEvent((newChats, [])));
        }
      });
  }

  void _onSearchbarShown(
    ChatListEvent event,
    Emitter<ChatListState> emit
  ) {
    emit(state.copyWith(
      isSearchBarShown: true
    ));
  }

  void _onSearchbarChanged(
    ChatListEvent event,
    Emitter<ChatListState> emit
  ) {
    emit(state.copyWith(
      isSearchBarEmpty: searchBarController.text.isEmpty
    ));
  }

  void _onItemsChanged(
    ChatListItemsChangedEvent event,
    Emitter<ChatListState> emit
  ) async {
    if (event.chatsUsers != null) {
      emit(state.copyWith(
        chatsUsers: event.chatsUsers
      ));
    } else if (searchBarController.text.isNotEmpty) {
      emit(state.copyWith(
        chatsUsers: await ChatService.fetchChatsAndUsersByQuery(searchBarController.text)
      ));
    } else {
      emit(state.copyWith(
        chatsUsers: (await ChatService.fetchChats(), [])
      ));
    }
  }

  void _onItemRemoved(
    ChatListItemRemovedEvent event,
    Emitter<ChatListState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await ChatService.removeChat(event.id);
    } finally {
      emit(state.copyWith(
        isLoading: false
      ));
    }
  }
}