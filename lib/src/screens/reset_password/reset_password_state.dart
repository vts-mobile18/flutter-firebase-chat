part of 'reset_password_bloc.dart';

final class ResetPasswordState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;

  ResetPasswordState({
    required this.isValid,
    required this.isLoading,
    required this.isSuccess,
    required this.error
  });

  ResetPasswordState.initial() :
    isValid = false,
    isLoading = false,
    isSuccess = false,
    error = '';

  ResetPasswordState copyWith({
    bool? isValid,
    bool? isLoading,
    bool? isSuccess,
    String? error
  }) =>
    ResetPasswordState(
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error
    );
}