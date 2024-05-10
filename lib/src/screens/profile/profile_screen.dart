import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/form_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/app_list_tile.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/confirm_alert.dart';
import 'package:flutter_firebase_chat/src/widgets/snack_bar.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'package:flutter_firebase_chat/src/screens/auth/auth.dart';
import 'profile_bloc.dart';

final class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

final class ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin<ProfileScreen> {
  late ProfileBloc _bloc;

  void _onFormChanged() {
    _bloc.add(ProfileFormChangedEvent());
  }

  void _savePressed() {
    _bloc.add(ProfileSavedEvent());
  }

  void _imagePressed(BuildContext context) {
    showAdaptiveActionSheet(
      context: context,
      actions: [
        BottomSheetAction(
          title: const Text('Take Photo'),
          onPressed: (_) {
            _bloc.add(ProfileImageFromCameraEvent());
            Navigator.pop(context);
          }
        ),
        BottomSheetAction(
          title: const Text('Photo from Library'),
          onPressed: (_) {
            _bloc.add(ProfileImageFromLibraryEvent());
            Navigator.pop(context);
          }
        )
      ],
      cancelAction: CancelAction(title: const Text('Cancel'))
    );
  }

  void _logoutPressed() {
    ConfirmAlert.open(
      context: context,
      title: 'Are you sure you want to logout?',
      onConfirm: () =>
        BlocProvider.of<AuthBloc>(context).add(AuthLoggedOutEvent())
    );
  }

  void _blocListener(
    BuildContext context,
    ProfileState state
  ) {
    if (state.isLoading) {
      Loader.open(context);
    } else if (state.isSuccess) {
      Loader.close(context);
      Snackbar.open(
        context: context,
        text: 'Saved'
      );
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
  void initState() {
    _bloc = BlocProvider.of<ProfileBloc>(context);
    _bloc.add(ProfileInitializedEvent());
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading ||
          previous.isSuccess != current.isSuccess ||
          previous.error != current.error,
      listener: _blocListener,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 30.h),
            children: [
              AppBarSecondary(
                title: 'Profile',
                buttonIconData: Icons.exit_to_app,
                onButtonPressed: _logoutPressed
              ),
              SizedBox(height: 34.h),
              AppListTile(
                leading: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (_, state) =>
                    CircleAvatar(
                      radius: 25.r,
                      backgroundColor: AppColors.blue,
                      backgroundImage: (state.profile != null) ?
                        (state.profile!.imageFile != null) ?
                          FileImage(state.profile!.imageFile!) as ImageProvider :
                          NetworkImage(state.profile!.imageUrl) :
                        null,
                      child: Icon(
                        Icons.camera_alt,
                        size: 25.r,
                        color: AppColors.white
                      )
                    )
                ),
                title: 'Upload a profile picture',
                onPressed: () =>
                  _imagePressed(context)
              ),
              SizedBox(height: 20.h),
              FormTextField(
                hintText: 'Username',
                controller: _bloc.usernameController,
                onChanged: _onFormChanged
              ),
              FormTextField(
                hintText: 'Email',
                controller: _bloc.emailController,
                onChanged: _onFormChanged,
                keyboardType: TextInputType.emailAddress,
                readOnly: true
              ),
              FormTextField(
                hintText: 'Password',
                controller: _bloc.passwordController,
                onChanged: _onFormChanged,
                obscureText: true
              ),
              FormTextField(
                hintText: 'Confirm Password',
                controller: _bloc.confirmPasswordController,
                onChanged: _onFormChanged,
                obscureText: true
              ),
              BlocSelector<ProfileBloc, ProfileState, bool>(
                selector: (state) => state.isValid,
                builder: (_, isValid) =>
                  FormButton(
                    text: 'Save',
                    onPressed: isValid ?
                      _savePressed : null
                  )
              )
            ]
          )
        )
      )
    );
  }
}