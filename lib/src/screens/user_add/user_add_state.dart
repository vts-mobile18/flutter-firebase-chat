part of 'user_add_bloc.dart';

final class UserAddState {
  final bool isSearchBarEmpty;
  final bool isLoading;
  final bool isUserSelected;
  final List<User> users;

  UserAddState({
    required this.isSearchBarEmpty,
    required this.isLoading,
    required this.isUserSelected,
    required this.users
  });

  UserAddState.initial() :
    isSearchBarEmpty = true,
    isLoading = false,
    isUserSelected = false,
    users = [];

  UserAddState copyWith({
    bool? isSearchBarEmpty,
    bool? isLoading,
    bool? isUserSelected,
    List<User>? users
  }) =>
    UserAddState(
      isSearchBarEmpty: isSearchBarEmpty ?? this.isSearchBarEmpty,
      isLoading: isLoading ?? this.isLoading,
      isUserSelected: isUserSelected ?? this.isUserSelected,
      users: users ?? this.users
    );
}