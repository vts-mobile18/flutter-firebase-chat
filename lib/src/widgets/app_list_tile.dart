import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';

final class AppListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? subTitle;
  final Widget? trailing;
  final Function() onPressed;

  const AppListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subTitle,
    this.trailing,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onPressed,
      child: Row(
        children: [
          leading,
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              mainAxisAlignment: subTitle != null ?
                MainAxisAlignment.spaceEvenly :
                MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black
                  )
                ),
                subTitle ?? Container()
              ]
            )
          ),
          trailing != null ?
            Container(
              margin: EdgeInsets.only(left: 20.w),
              child: trailing
            ) :
            Container()
        ]
      )
    );
  }
}