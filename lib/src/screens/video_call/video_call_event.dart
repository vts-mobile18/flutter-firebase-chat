part of 'video_call_bloc.dart';

abstract base class VideoCallEvent {}

final class VideoCallInitializedEvent extends VideoCallEvent {}

final class VideoCallRemoteUserIdUpdatedEvent extends VideoCallEvent {
  final int remoteUserId;
  VideoCallRemoteUserIdUpdatedEvent(this.remoteUserId);
}

final class VideoCallMutedEvent extends VideoCallEvent {}

final class VideoCallCameraSwitchedEvent extends VideoCallEvent {}