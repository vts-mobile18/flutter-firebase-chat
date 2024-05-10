part of 'reset_password_bloc.dart';

abstract base class ResetPasswordEvent {}
final class ResetPasswordFormChangedEvent extends ResetPasswordEvent {}
final class ResetPasswordPressedEvent extends ResetPasswordEvent {}