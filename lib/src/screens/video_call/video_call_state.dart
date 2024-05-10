part of 'video_call_bloc.dart';

final class VideoCallState {
  final bool isLocalUserJoined;
  final int remoteUserId;
  final bool muted;

  VideoCallState({
    required this.isLocalUserJoined,
    required this.remoteUserId,
    required this.muted
  });

  VideoCallState.initial() :
    isLocalUserJoined = false,
    remoteUserId = 0,
    muted = false;

  VideoCallState copyWith({
    bool? isLocalUserJoined,
    int? remoteUserId,
    bool? muted,
  }) =>
    VideoCallState(
      isLocalUserJoined: isLocalUserJoined ?? this.isLocalUserJoined,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      muted: muted ?? this.muted
    );
}