part of 'auth_bloc.dart';

abstract base class AuthState {}
final class AuthUninitializedState extends AuthState {}
final class AuthAuthenticatedState extends AuthState {}
final class AuthUnauthenticatedState extends AuthState {}