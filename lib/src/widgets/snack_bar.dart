import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

abstract final class Snackbar {
  static void open({
    required BuildContext context,
    required String text,
    Color? color
  }) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? AppColors.blue,
        content: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.white
          )
        )
      )
    );
}