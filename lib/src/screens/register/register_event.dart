part of 'register_bloc.dart';

abstract base class RegisterEvent {}
final class RegisterFormChangedEvent extends RegisterEvent {}
final class RegisterImageFromCameraEvent extends RegisterEvent {}
final class RegisterImageFromLibraryEvent extends RegisterEvent {}
final class RegisterPressedEvent extends RegisterEvent {}