part of 'chat_list_bloc.dart';

final class ChatListState {
  final bool isSearchBarShown;
  final bool isSearchBarEmpty;
  final bool isLoading;
  final (List<Chat>, List<User>) chatsUsers;

  ChatListState({
    required this.isSearchBarShown,
    required this.isSearchBarEmpty,
    required this.isLoading,
    required this.chatsUsers
  });

  ChatListState.initial() :
    isSearchBarShown = false,
    isSearchBarEmpty = true,
    isLoading = false,
    chatsUsers = ([], []);

  ChatListState copyWith({
    bool? isSearchBarShown,
    bool? isSearchBarEmpty,
    bool? isLoading,
    (List<Chat>, List<User>)? chatsUsers
  }) =>
    ChatListState(
      isSearchBarShown: isSearchBarShown ?? this.isSearchBarShown,
      isSearchBarEmpty: isSearchBarEmpty ?? this.isSearchBarEmpty,
      isLoading: isLoading ?? this.isLoading,
      chatsUsers: chatsUsers ?? this.chatsUsers
    );
}