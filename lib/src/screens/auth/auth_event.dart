part of 'auth_bloc.dart';

abstract base class AuthEvent {}
final class AuthStartedEvent extends AuthEvent {}
final class AuthLoggedInEvent extends AuthEvent {}
final class AuthLoggedOutEvent extends AuthEvent {}