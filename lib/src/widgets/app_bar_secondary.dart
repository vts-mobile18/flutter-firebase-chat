import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'app_icon_button.dart';

final class AppBarSecondary extends StatelessWidget {
  final String title;
  final IconData? buttonIconData;
  final Function()? onButtonPressed;

  const AppBarSecondary({
    super.key,
    required this.title,
    this.buttonIconData,
    this.onButtonPressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black
            )
          )
        ),
        (buttonIconData != null && onButtonPressed != null) ?
          AppIconButton(
            height: 38.h,
            padding: EdgeInsets.only(left: 10.w),
            icon: Icon(
              buttonIconData,
              color: AppColors.black,
              size: 25.r
            ),
            onPressed: onButtonPressed
          ) :
          Container()
      ]
    );
  }
}