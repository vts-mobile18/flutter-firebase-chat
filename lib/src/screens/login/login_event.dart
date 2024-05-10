part of 'login_bloc.dart';

abstract base class LoginEvent {}
final class LoginFormChangedEvent extends LoginEvent {}
final class LoginPressedEvent extends LoginEvent {}