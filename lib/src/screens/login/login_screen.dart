import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/form_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/form_button.dart';
import 'package:flutter_firebase_chat/src/widgets/form_text_button.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/snack_bar.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'package:flutter_firebase_chat/src/screens/auth/auth.dart';
import 'package:flutter_firebase_chat/src/screens/register/register.dart';
import 'package:flutter_firebase_chat/src/screens/reset_password/reset_password.dart';
import 'login_bloc.dart';

final class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onFormChanged(LoginBloc bloc) {
    bloc.add(LoginFormChangedEvent());
  }

  void _signInPressed(LoginBloc bloc) {
    bloc.add(LoginPressedEvent());
  }

  void _signUpPressed(BuildContext context) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        BlocProvider<RegisterBloc>(
          create: (_) => RegisterBloc(),
          child: const RegisterScreen()
        )
      )
    );
  }

  void _forgotPasswordPressed(BuildContext context) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        BlocProvider<ResetPasswordBloc>(
          create: (_) => ResetPasswordBloc(),
          child: const ResetPasswordScreen()
        )
      )
    );
  }

  void _blocListener(
    BuildContext context,
    LoginState state
  ) {
    if (state.isLoading) {
      Loader.open(context);
    } else if (state.isSuccess) {
      Loader.close(context);
      BlocProvider.of<AuthBloc>(context).add(AuthLoggedInEvent());
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
    LoginBloc bloc = BlocProvider.of<LoginBloc>(context);
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading ||
          previous.isSuccess != current.isSuccess ||
          previous.error != current.error,
      listener: _blocListener,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppBarSecondary(title: 'Login'),
                SizedBox(height: 20.h),
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
                BlocSelector<LoginBloc, LoginState, bool>(
                  selector: (state) => state.isValid,
                  builder: (_, isValid) =>
                    FormButton(
                      text: 'Login',
                      onPressed: isValid ?
                        () => _signInPressed(bloc) :
                        null
                    )
                ),
                FormTextButton(
                  text: 'Register',
                  onPressed: () =>
                    _signUpPressed(context)
                ),
                FormTextButton(
                  text: 'Forgot Password?',
                  onPressed: () =>
                    _forgotPasswordPressed(context)
                )
              ]
            )
          )
        )
      )
    );
  }
}