import 'dart:io';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/models/profile_model.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
part 'profile_event.dart';
part 'profile_state.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  Profile? _profile;

  ProfileBloc() : super(ProfileState.initial()) {
    on<ProfileInitializedEvent>(_onInitialized);
    on<ProfileFormChangedEvent>(_onFormChanged);
    on<ProfileImageFromCameraEvent>((event, emit) =>
      _onImageChanged(event, emit, ImageSource.camera)
    );
    on<ProfileImageFromLibraryEvent>((event, emit) =>
      _onImageChanged(event, emit, ImageSource.gallery)
    );
    on<ProfileSavedEvent>(_onSavedPressed);
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }

  void _onInitialized(
    ProfileEvent event,
    Emitter<ProfileState> emit
  ) async {
    _profile = await AuthService.fetchProfile();
    usernameController.text = _profile!.username;
    emailController.text = _profile!.email;
    passwordController.text = _profile!.password;
    confirmPasswordController.text = _profile!.confirmPassword;
    emit(state.copyWith(
      profile: _profile
    ));
  }

  void _onFormChanged(
    ProfileEvent event,
    Emitter<ProfileState> emit
  ) {
    _profile!.username = usernameController.text;
    _profile!.password = passwordController.text;
    _profile!.confirmPassword = confirmPasswordController.text;
    emit(state.copyWith(
      isValid: usernameController.text.isNotEmpty &&
        EmailValidator.validate(emailController.text) &&
        (passwordController.text == confirmPasswordController.text)
    ));
  }

  void _onImageChanged(
    ProfileEvent event,
    Emitter<ProfileState> emit,
    ImageSource imageSource
  ) async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: imageSource,
      maxWidth: 400
    );
    if (pickedImage != null) {
      _profile!.imageFile = File(pickedImage.path);
      emit(state.copyWith(
        profile: _profile
      ));
    }
  }

  void _onSavedPressed(
    ProfileEvent event,
    Emitter<ProfileState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await AuthService.updateProfile(_profile!);
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
      emit(ProfileState.initial());
      emit(state.copyWith(
        profile: _profile
      ));
    }
  }
}