import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/video_call_service.dart';
part 'video_call_event.dart';
part 'video_call_state.dart';

final class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final String chatId;
  late VideoCallService _videoCallService;
  late RtcEngine rtcEngine;

  VideoCallBloc(this.chatId) : super(VideoCallState.initial()) {
    on<VideoCallInitializedEvent>(_onInitialized);
    on<VideoCallRemoteUserIdUpdatedEvent>(_onRemoteUserIdUpdated);
    on<VideoCallMutedEvent>(_onMuted);
    on<VideoCallCameraSwitchedEvent>(_onCameraSwitched);
  }

  @override
  Future<void> close() async {
    await _videoCallService.dispose();
    return super.close();
  }

  void _onInitialized(
    VideoCallEvent event,
    Emitter<VideoCallState> emit
  ) async {
    _videoCallService = VideoCallService(
      chatId: chatId,
      onUserJoined: (userId) {
        if (state.remoteUserId == 0) {
          add(VideoCallRemoteUserIdUpdatedEvent(userId));
        }
      },
      onUserOffline: (userId) {
        if (state.remoteUserId == userId) {
          add(VideoCallRemoteUserIdUpdatedEvent(0));
        }
      }
    );
    rtcEngine = _videoCallService.rtcEngine;
    emit(state.copyWith(
      isLocalUserJoined: true
    ));
  }

  void _onRemoteUserIdUpdated(
    VideoCallRemoteUserIdUpdatedEvent event,
    Emitter<VideoCallState> emit
  ) {
    emit(state.copyWith(
      remoteUserId: event.remoteUserId
    ));
  }

  void _onMuted(
    VideoCallEvent event,
    Emitter<VideoCallState> emit
  ) async {
    await _videoCallService.muteAudio(!state.muted);
    emit(state.copyWith(
      muted: !state.muted
    ));
  }

  void _onCameraSwitched(
    VideoCallEvent event,
    Emitter<VideoCallState> emit
  ) async {
    await _videoCallService.switchCamera();
  }
}