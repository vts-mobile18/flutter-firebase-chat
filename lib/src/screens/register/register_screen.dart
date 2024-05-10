import 'dart:io';
import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/form_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_primary.dart';
import 'package:flutter_firebase_chat/src/widgets/app_list_tile.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/snack_bar.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'package:flutter_firebase_chat/src/screens/auth/auth.dart';
import 'register_bloc.dart';

final class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _onFormChanged(RegisterBloc bloc) {
    bloc.add(RegisterFormChangedEvent());
  }

  void _signUpPressed(RegisterBloc bloc) {
    bloc.add(RegisterPressedEvent());
  }

  void _imagePressed(
    BuildContext context,
    RegisterBloc bloc
  ) {
    showAdaptiveActionSheet(
      context: context,
      actions: [
        BottomSheetAction(
          title: const Text('Take Photo'),
          onPressed: (_) {
            bloc.add(RegisterImageFromCameraEvent());
            Navigator.pop(context);
          }
        ),
        BottomSheetAction(
          title: const Text('Photo from Library'),
          onPressed: (_) {
            bloc.add(RegisterImageFromLibraryEvent());
            Navigator.pop(context);
          }
        )
      ],
      cancelAction: CancelAction(title: const Text('Cancel'))
    );
  }

  void _blocListener(
    BuildContext context,
    RegisterState state
  ) {
    if (state.isLoading) {
      Loader.open(context);
    } else if (state.isSuccess) {
      Loader.close(context);
      BlocProvider.of<AuthBloc>(context).add(AuthLoggedInEvent());
      Navigator.pop(context);
    } else if (state.error.isNotEmpty) {
      Loader.close(context);
      Snackbar.open(
        context: context,
        text: state.error,
        color: AppColors.red
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    RegisterBloc bloc = BlocProvider.of<RegisterBloc>(context);
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading ||
          previous.isSuccess != current.isSuccess ||
          previous.error != current.error,
      listener: _blocListener,
      child: Scaffold(
        appBar: const AppBarPrimary(
          leftButton: AppBarPrimaryBackButton()
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(30.w, 22.h, 30.w, 30.h),
          children: [
            const AppBarSecondary(title: 'Register'),
            SizedBox(height: 34.h),
            AppListTile(
              leading: BlocSelector<RegisterBloc, RegisterState, File?>(
                selector: (state) => state.imageFile,
                builder: (_, imageFile) =>
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor: AppColors.blue,
                    backgroundImage: (imageFile != null) ?
                      FileImage(imageFile) : null,
                    child: Icon(
                      Icons.camera_alt,
                      size: 25.r,
                      color: AppColors.white
                    )
                  )
              ),
              title: 'Upload a profile picture',
              onPressed: () =>
                _imagePressed(context, bloc)
            ),
            SizedBox(height: 20.h),
            FormTextField(
              hintText: 'Username',
              controller: bloc.usernameController,
              onChanged: () =>
                _onFormChanged(bloc)
            ),
            FormTextField(
              hintText: 'Email',
              controller: bloc.emailController,
              onChanged: () =>
                _onFormChanged(bloc),
              keyboardType: TextInputType.emailAddress
            ),
            FormTextField(
              hintText: 'Password',
              controller: bloc.passwordController,
              onChanged: () =>
                _onFormChanged(bloc),
              obscureText: true
            ),
            FormTextField(
              hintText: 'Confirm Password',
              controller: bloc.confirmPasswordController,
              onChanged: () =>
                _onFormChanged(bloc),
              obscureText: true
            ),
            BlocSelector<RegisterBloc, RegisterState, bool>(
              selector: (state) => state.isValid,
              builder: (_, isValid) =>
                FormButton(
                  text: 'Register',
                  onPressed: isValid ?
                    () => _signUpPressed(bloc) :
                    null
                )
            )
          ]
        )
      )
    );
  }
}