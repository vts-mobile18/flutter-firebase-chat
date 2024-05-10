import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_primary.dart';
import 'package:flutter_firebase_chat/src/widgets/form_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/snack_bar.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'reset_password_bloc.dart';

final class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  void _onFormChanged(ResetPasswordBloc bloc) {
    bloc.add(ResetPasswordFormChangedEvent());
  }

  void _resetPasswordPressed(ResetPasswordBloc bloc) {
    bloc.add(ResetPasswordPressedEvent());
  }

  void _blocListener(
    BuildContext context,
    ResetPasswordState state,
    ResetPasswordBloc bloc
  ) {
    if (state.isLoading) {
      Loader.open(context);
    } else if (state.isSuccess) {
      bloc.emailController.text = '';
      _onFormChanged(bloc);
      Loader.close(context);
      Snackbar.open(
        context: context,
        text: 'An email has been sent. Please click the link when you get it.'
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
  Widget build(BuildContext context) {
    ResetPasswordBloc bloc = BlocProvider.of<ResetPasswordBloc>(context);
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading ||
          previous.isSuccess != current.isSuccess ||
          previous.error != current.error,
      listener: (context, state) =>
        _blocListener(context, state, bloc),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppBarPrimary(
          leftButton: AppBarPrimaryBackButton()
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30.w, 22.h, 30.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBarSecondary(title: 'Forgot Password?'),
              SizedBox(height: 20.h),
              FormTextField(
                hintText: 'Email',
                controller: bloc.emailController,
                onChanged: () =>
                  _onFormChanged(bloc),
                keyboardType: TextInputType.emailAddress
              ),
              BlocSelector<ResetPasswordBloc, ResetPasswordState, bool>(
                selector: (state) => state.isValid,
                builder: (_, isValid) =>
                  FormButton(
                    text: 'Reset Password',
                    onPressed: isValid ?
                      () => _resetPasswordPressed(bloc) :
                      null
                  )
              )
            ]
          )
        )
      )
    );
  }
}