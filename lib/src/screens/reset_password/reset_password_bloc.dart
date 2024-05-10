import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
part 'reset_password_event.dart';
part 'reset_password_state.dart';

final class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final TextEditingController emailController = TextEditingController();

  ResetPasswordBloc() : super(ResetPasswordState.initial()) {
    on<ResetPasswordFormChangedEvent>((event, emit) =>
      _validate(emit)
    );
    on<ResetPasswordPressedEvent>(_onResetPressed);
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }

  void _validate(Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(
      isValid: EmailValidator.validate(emailController.text)
    ));
  }

  void _onResetPressed(
    ResetPasswordEvent event,
    Emitter<ResetPasswordState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await AuthService.resetPassword(emailController.text);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: error.toString()
      ));
    } finally {
      emit(ResetPasswordState.initial());
      _validate(emit);
    }
  }
}