part of 'register_bloc.dart';

final class RegisterState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;
  final File? imageFile;

  RegisterState({
    required this.isValid,
    required this.isLoading,
    required this.isSuccess,
    required this.error,
    required this.imageFile
  });

  RegisterState.initial() :
    isValid = false,
    isLoading = false,
    isSuccess = false,
    error = '',
    imageFile = null;

  RegisterState copyWith({
    bool? isValid,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    File? imageFile
  }) =>
    RegisterState(
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      imageFile: imageFile ?? this.imageFile
    );
}