import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/screens/chat_list/chat_list.dart';
import 'package:flutter_firebase_chat/src/screens/profile/profile.dart';

final class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<_Item> items = [
      _Item(
        screen: BlocProvider<ChatListBloc>(
          create: (_) => ChatListBloc(),
          child: const ChatListScreen()
        ),
        icon: Icons.question_answer
      ),
      _Item(
        screen: BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(),
          child: const ProfileScreen()
        ),
        icon: Icons.person
      )
    ];
    return DefaultTabController(
      length: items.length,
      child: Scaffold(
        body: TabBarView(
          children: items.map((item) => item.screen).toList()
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.white,
            height: 45.h,
            child: TabBar(
              unselectedLabelColor: AppColors.lightGrey,
              labelColor: AppColors.blue,
              indicatorColor: Colors.transparent,
              tabs: items.map((item) => _TabBuilder(item.icon)).toList()
            )
          )
        )
      )
    );
  }
}

final class _TabBuilder extends StatelessWidget {
  final IconData icon;
  const _TabBuilder(this.icon);

  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: Icon(
        icon,
        size: 25.r
      )
    );
  }
}

final class _Item {
  final Widget screen;
  final IconData icon;

  _Item({
    required this.screen,
    required this.icon
  });
}