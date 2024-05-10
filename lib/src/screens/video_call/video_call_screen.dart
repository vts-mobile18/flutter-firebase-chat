import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/app_icon_button.dart';
import 'video_call_bloc.dart';

final class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  void _mutePressed(VideoCallBloc bloc) {
    bloc.add(VideoCallMutedEvent());
  }

  void _switchCameraPressed(VideoCallBloc bloc) {
    bloc.add(VideoCallCameraSwitchedEvent());
  }

  @override
  Widget build(BuildContext context) {
    VideoCallBloc bloc = BlocProvider.of<VideoCallBloc>(context);
    bloc.add(VideoCallInitializedEvent());
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          BlocSelector<VideoCallBloc, VideoCallState, int>(
            selector: (state) => state.remoteUserId,
            builder: (_, remoteUserId) =>
              (remoteUserId != 0) ?
                AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: bloc.rtcEngine,
                    canvas: VideoCanvas(uid: remoteUserId),
                    connection: RtcConnection(channelId: bloc.chatId)
                  )
                ) :
                Container()
          ),
          Positioned(
            bottom: 20.r,
            left: 20.r,
            right: 20.r,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocSelector<VideoCallBloc, VideoCallState, bool>(
                    selector: (state) => state.isLocalUserJoined,
                    builder: (_, isLocalUserJoined) =>
                      isLocalUserJoined ?
                        Container(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.height / 4,
                          margin: EdgeInsets.only(bottom: 20.r),
                          color: AppColors.black,
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: bloc.rtcEngine,
                              canvas: const VideoCanvas(uid: 0)
                            )
                          )
                        ) :
                        Container()
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BlocSelector<VideoCallBloc, VideoCallState, bool>(
                        selector: (state) => state.muted,
                        builder: (_, muted) =>
                          AppIconButton(
                            padding: EdgeInsets.all(12.r),
                            icon: Icon(
                              muted ? Icons.mic_off : Icons.mic,
                              color: AppColors.black,
                              size: 20.r
                            ),
                            shape: const CircleBorder(),
                            backgroundColor: AppColors.white,
                            onPressed: () => _mutePressed(bloc)
                          )
                      ),
                      AppIconButton(
                        padding: EdgeInsets.all(15.r),
                        icon: Icon(
                          Icons.call_end,
                          color: AppColors.white,
                          size: 35.r
                        ),
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.red,
                        onPressed: () => Navigator.pop(context)
                      ),
                      AppIconButton(
                        padding: EdgeInsets.all(12.r),
                        icon: Icon(
                          Icons.switch_camera,
                          color: AppColors.black,
                          size: 20.r
                        ),
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.white,
                        onPressed: () => _switchCameraPressed(bloc)
                      )
                    ]
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }
}