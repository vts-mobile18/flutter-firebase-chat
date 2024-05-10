import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

final class FormButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;

  const FormButton({
    super.key,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)
              )
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) =>
              states.contains(MaterialState.disabled) ?
                AppColors.lightGrey : AppColors.blue
            )
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.white
            )
          )
        )
      )
    );
  }
}