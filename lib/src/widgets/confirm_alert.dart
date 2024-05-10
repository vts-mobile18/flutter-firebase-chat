import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

abstract final class ConfirmAlert {
  static void open ({
    required BuildContext context,
    required String title,
    required Function() onConfirm
  }) =>
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
        AlertDialog(
          backgroundColor: AppColors.white,
          contentPadding: EdgeInsets.all(30.r),
          actionsPadding: EdgeInsets.zero,
          content: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.black
            )
          ),
          actions: [
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.blue
                )
              ),
              onPressed: () =>
                Navigator.pop(context)
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              }
            )
          ]
        )
    );
}