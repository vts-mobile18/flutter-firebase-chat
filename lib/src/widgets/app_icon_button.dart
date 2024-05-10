import 'package:flutter/material.dart';

final class AppIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final Icon icon;
  final Function()? onPressed;

  const AppIconButton({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.shape,
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashColor: Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      constraints: BoxConstraints(
        minWidth: width ?? 0,
        minHeight: height ?? 0
      ),
      padding: padding ?? EdgeInsets.zero,
      fillColor: backgroundColor ?? Colors.transparent,
      shape: shape ?? const RoundedRectangleBorder(),
      onPressed: onPressed,
      child: icon
    );
  }
}