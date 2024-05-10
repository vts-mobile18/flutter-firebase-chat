import 'dart:io';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
part 'register_event.dart';
part 'register_state.dart';

final class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  File? _imageFile;

  RegisterBloc() : super(RegisterState.initial()) {
    on<RegisterFormChangedEvent>((event, emit) =>
      _validate(emit)
    );
    on<RegisterImageFromCameraEvent>((event, emit) =>
      _onImageChanged(event, emit, ImageSource.camera)
    );
    on<RegisterImageFromLibraryEvent>((event, emit) =>
      _onImageChanged(event, emit, ImageSource.gallery)
    );
    on<RegisterPressedEvent>(_onRegisterPressed);
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }

  void _validate(Emitter<RegisterState> emit) {
    emit(state.copyWith(
      isValid: (_imageFile != null) &&
        usernameController.text.isNotEmpty &&
        EmailValidator.validate(emailController.text) &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        (passwordController.text == confirmPasswordController.text)
    ));
  }

  void _onImageChanged(
    RegisterEvent event,
    Emitter<RegisterState> emit,
    ImageSource imageSource
  ) async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: imageSource,
      maxWidth: 400
    );
    if (pickedImage != null) {
      _imageFile = File(pickedImage.path);
      emit(state.copyWith(
        imageFile: _imageFile
      ));
      _validate(emit);
    }
  }

  void _onRegisterPressed(
    RegisterEvent event,
    Emitter<RegisterState> emit
  ) async {
    emit(state.copyWith(
      isLoading: true
    ));
    try {
      await AuthService.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
        _imageFile!
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
      emit(RegisterState.initial());
      emit(state.copyWith(
        imageFile: _imageFile
      ));
      _validate(emit);
    }
  }
}