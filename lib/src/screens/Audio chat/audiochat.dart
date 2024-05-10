import 'dart:html';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Audio controller.dart';


class Audio extends StatefulWidget {
  const Audio({super.key});

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {

  TextEditingController messageController = TextEditingController();

  // late ChatProvider chatProvider;
  bool temp = false;
  bool audio = false;
  int _limit = 20;
  int _limitIncrement = 20;
  List<QueryDocumentSnapshot> listMessage = [];

  Stream<QuerySnapshot>? chatMessageStream;
  final ScrollController _scrollController = ScrollController();
  String groupChatId = "";
  bool isShowSticker = false;
  final FocusNode focusNode = FocusNode();
  String currentUserId = "";

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();
  String audioURL = "";

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
