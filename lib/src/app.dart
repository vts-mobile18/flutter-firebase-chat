import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/screens/auth/auth_bloc.dart';
import 'package:flutter_firebase_chat/src/screens/login/login.dart';
import 'package:flutter_firebase_chat/src/screens/tabs/tabs.dart';

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(AuthStartedEvent()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (_, state) {
          late Widget home;
          switch (state) {
            case AuthUninitializedState():
              home = const Scaffold();
            case AuthAuthenticatedState():
              home = const TabsScreen();
            case AuthUnauthenticatedState():
              home = BlocProvider<LoginBloc>(
                create: (_) => LoginBloc(),
                child: const LoginScreen()
              );
          }
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => KeyboardDismisser(
              gestures: const [
                GestureType.onTap,
                GestureType.onPanUpdateDownDirection
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Firebase Chat',
                theme: ThemeData(
                  fontFamily: 'Lato-Regular',
                  scaffoldBackgroundColor: AppColors.white
                ),
                home: home
              )
            )
          );
        }
      )
    );
  }
}