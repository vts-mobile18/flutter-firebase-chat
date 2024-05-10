import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

final class FormTextButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;

  const FormTextButton({
    super.key,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.black
          )
        )
      )
    );
  }
}