part of 'profile_bloc.dart';

final class ProfileState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;
  final Profile? profile;

  ProfileState({
    required this.isValid,
    required this.isLoading,
    required this.isSuccess,
    required this.error,
    required this.profile
  });

  ProfileState.initial() :
    isValid = true,
    isLoading = false,
    isSuccess = false,
    error = '',
    profile = null;

  ProfileState copyWith({
    bool? isFetched,
    bool? isValid,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Profile? profile
  }) =>
    ProfileState(
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      profile: profile ?? this.profile
    );
}