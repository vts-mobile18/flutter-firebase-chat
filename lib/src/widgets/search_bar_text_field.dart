import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/app_icon_button.dart';

final class SearchBarTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool showClearButton;
  final Function() onClearPressed;
  final Function() onChanged;
  final Function() onChangedWithDelay;

  const SearchBarTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.showClearButton,
    required this.onClearPressed,
    required this.onChanged,
    required this.onChangedWithDelay
  });

  @override
  SearchBarTextFieldState createState() => SearchBarTextFieldState();
}

final class SearchBarTextFieldState extends State<SearchBarTextField> {
  Timer? _searchBarDebounceTimer;

  @override
  void dispose() {
    _searchBarDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      padding: EdgeInsets.only(left: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.lightGrey
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.grey,
            size: 20.r
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10.w),
              child: TextField(
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.black
                ),
                controller: widget.controller,
                onChanged: (_) {
                  widget.onChanged();
                  if (_searchBarDebounceTimer?.isActive ?? false) {
                    _searchBarDebounceTimer!.cancel();
                  }
                  _searchBarDebounceTimer = Timer(
                    const Duration(milliseconds: 1000), () =>
                      widget.onChangedWithDelay()
                  );
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.grey
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: InputBorder.none
                )
              )
            )
          ),
          widget.showClearButton ?
            AppIconButton(
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              icon: Icon(
                Icons.cancel,
                color: AppColors.grey,
                size: 20.r
              ),
              onPressed: widget.onClearPressed
            ) :
            Container()
        ]
      )
    );
  }
}