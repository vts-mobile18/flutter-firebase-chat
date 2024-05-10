part of 'user_add_bloc.dart';

abstract base class UserAddEvent {}

final class UserAddSearchBarChangedEvent extends UserAddEvent {}

final class UserAddFetchedEvent extends UserAddEvent {}

final class UserAddSelectedEvent extends UserAddEvent {
  final String id;
  UserAddSelectedEvent(this.id);
}