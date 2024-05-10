import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

final class FormTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function() onChanged;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final bool? obscureText;

  const FormTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.readOnly,
    this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: TextField(
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.black
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.grey
          ),
          enabledBorder: UnderlineInputBorder(      
            borderSide: BorderSide(
              color: AppColors.grey,
              width: 1.5.h
            )   
          ),  
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.blue,
              width: 2.h
            )
          )
        ),
        controller: controller,
        onChanged: (_) => onChanged(),
        keyboardType: keyboardType ?? TextInputType.text,
        readOnly: readOnly ?? false,
        obscureText: obscureText ?? false
      )
    );
  }
}