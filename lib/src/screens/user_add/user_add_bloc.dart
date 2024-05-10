import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
part 'user_add_event.dart';
part 'user_add_state.dart';

final class UserAddBloc extends Bloc<UserAddEvent, UserAddState> {
  final Chat chat;
  final TextEditingController searchBarController = TextEditingController();

  UserAddBloc(this.chat) : super(UserAddState.initial()) {
    on<UserAddSearchBarChangedEvent>(_onSearchbarChanged);
    on<UserAddFetchedEvent>(_onFetched);
    on<UserAddSelectedEvent>(_onSelected);
  }

  @override
  Future<void> close() {
    searchBarController.dispose();
    return super.close();
  }

  void _onSearchbarChanged(
    UserAddEvent event,
    Emitter<UserAddState> emit
  ) {
    emit(state.copyWith(
      isSearchBarEmpty: searchBarController.text.isEmpty
    ));
  }

  void _onFetched(
    UserAddEvent event,
    Emitter<UserAddState> emit
  ) async {
    emit(state.copyWith(
      users: await ChatService.fetchUsersByQueryExceptMembers(
        searchBarController.text, chat.members
      )
    ));
  }

  void _onSelected(
    UserAddSelectedEvent event,
    Emitter<UserAddState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await ChatService.addChatMember(
        chat, event.id
      );
      emit(state.copyWith(
        isLoading: false,
        isUserSelected: true
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false
      ));
    }
  }
}