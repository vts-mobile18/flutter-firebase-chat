import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

abstract final class Loader {
  static void open(BuildContext context) =>
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue)
        )
      )
    );

  static void close(BuildContext context) =>
    Navigator.pop(context);
}