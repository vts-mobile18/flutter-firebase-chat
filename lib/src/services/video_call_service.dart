import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_firebase_chat/src/app_constants.dart';
import 'auth_service.dart';

final class VideoCallService {
  final String chatId;
  final Function(int) onUserJoined;
  final Function(int) onUserOffline;
  final RtcEngine rtcEngine = createAgoraRtcEngine();

  VideoCallService({
    required this.chatId,
    required this.onUserJoined,
    required this.onUserOffline
  }) {
    _init();
  }

  Future<void> _init() async {
    await rtcEngine.initialize(const RtcEngineContext(appId: AppConstants.agoraAppId));
    rtcEngine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (_, uid, __) =>
        onUserJoined(uid),
      onUserOffline: (_, uid, __) =>
        onUserOffline(uid),
      onError: (_, error) =>
        // ignore: avoid_print
        print('AgoraRtcEngine Error: $error')
    ));
    await rtcEngine.enableVideo();
    await rtcEngine.startPreview();
    await rtcEngine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await rtcEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    return rtcEngine.joinChannelWithUserAccount(
      token: '',
      channelId: chatId,
      userAccount: AuthService.fetchCurrentUserId()
    );
  }

  Future<void> muteAudio(bool muted) =>
    rtcEngine.muteLocalAudioStream(muted);

  Future<void> switchCamera() =>
    rtcEngine.switchCamera();

  Future<void> dispose() async {
    await rtcEngine.leaveChannel();
    return rtcEngine.release();
  }
}