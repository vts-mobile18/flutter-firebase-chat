part of 'profile_bloc.dart';

abstract base class ProfileEvent {}
final class ProfileInitializedEvent extends ProfileEvent {}
final class ProfileFormChangedEvent extends ProfileEvent {}
final class ProfileImageFromCameraEvent extends ProfileEvent {}
final class ProfileImageFromLibraryEvent extends ProfileEvent {}
final class ProfileSavedEvent extends ProfileEvent {}