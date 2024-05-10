import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
part 'login_event.dart';
part 'login_state.dart';

final class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginBloc() : super(LoginState.initial()) {
    on<LoginFormChangedEvent>((event, emit) =>
      _validate(emit)
    );
    on<LoginPressedEvent>(_onLoginPressed);
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }

  void _validate(Emitter<LoginState> emit) {
    emit(state.copyWith(
      isValid: EmailValidator.validate(emailController.text) &&
        passwordController.text.isNotEmpty
    ));
  }

  void _onLoginPressed(
    LoginEvent event,
    Emitter<LoginState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await AuthService.login(
        emailController.text,
        passwordController.text
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        error: error.toString()
      ));
      emit(LoginState.initial());
      _validate(emit);
    }
  }
}