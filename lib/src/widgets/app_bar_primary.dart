import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'app_icon_button.dart';

final class AppBarPrimary extends StatelessWidget implements PreferredSizeWidget {
  static final double preferredSizeHeight = 50.h;
  final Widget? leftButton;
  final Widget? title;
  final List<Widget>? rightButtons;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final Color? color;
  final Border? border;

  const AppBarPrimary({
    super.key,
    this.leftButton,
    this.title,
    this.rightButtons,
    this.systemUiOverlayStyle = SystemUiOverlayStyle.dark,
    this.color,
    this.border
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiOverlayStyle!,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.white,
            border: border
          ),
          child: SafeArea(
            child: Row(
              children: [
                leftButton ?? Container(),
                title ?? Container(),
                (rightButtons != null) ?
                  Row(
                    children: rightButtons!
                  ) :
                  Container()
              ]
            )
          )
        )
      )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(preferredSizeHeight);
}

final class AppBarPrimaryBackButton extends StatelessWidget {
  final Color? color;

  const AppBarPrimaryBackButton({
    super.key,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      height: AppBarPrimary.preferredSizeHeight,
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      icon: Icon(
        Icons.arrow_back,
        color: color ?? AppColors.black,
        size: 30.r
      ),
      onPressed: () => Navigator.pop(context)
    );
  }
}

final class AppBarPrimaryTitle extends StatelessWidget {
  final String title;

  const AppBarPrimaryTitle(
    this.title, {
      super.key
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.black
        )
      )
    );
  }
}