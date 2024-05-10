part of 'login_bloc.dart';

final class LoginState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;

  LoginState({
    required this.isValid,
    required this.isLoading,
    required this.isSuccess,
    required this.error
  });

  LoginState.initial() :
    isValid = false,
    isLoading = false,
    isSuccess = false,
    error = '';

  LoginState copyWith({
    bool? isValid,
    bool? isLoading,
    bool? isSuccess,
    String? error
  }) =>
    LoginState(
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error
    );
}