import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_primary.dart';

final class ImageView extends StatelessWidget {
  final String url;

  const ImageView(
    this.url, {
      super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppBarPrimary(
        leftButton: AppBarPrimaryBackButton(
          color: AppColors.white
        ),
        systemUiOverlayStyle: SystemUiOverlayStyle.light,
        color: Colors.transparent
      ),
      body: PhotoView(
        imageProvider: NetworkImage(url)
      )
    );
  }
}