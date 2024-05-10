import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_primary.dart';
import 'package:flutter_firebase_chat/src/widgets/search_bar_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/app_list_tile.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'user_add_bloc.dart';

final class UserAddScreen extends StatelessWidget {
  const UserAddScreen({super.key});

  void _onSearchBarChanged(UserAddBloc bloc) {
    bloc.add(UserAddSearchBarChangedEvent());
  }

  void _onSearchBarChangedWithDelay(UserAddBloc bloc) {
    bloc.add(UserAddFetchedEvent());
  }

  void _clearSearchBarPressed(UserAddBloc bloc) {
    bloc.searchBarController.text = '';
    _onSearchBarChanged(bloc);
    bloc.add(UserAddFetchedEvent());
  }

  void _userPressed(
    String userId,
    UserAddBloc bloc
  ) {
    bloc.add(UserAddSelectedEvent(userId));
  }

  void _blocListener(
    BuildContext context,
    UserAddState state
  ) {
    if (state.isLoading) {
      Loader.open(context);
    } else if (state.isUserSelected) {
      Loader.close(context);
      Navigator.pop(context);
    } else {
      Loader.close(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserAddBloc bloc = BlocProvider.of<UserAddBloc>(context);
    bloc.add(UserAddFetchedEvent());
    return BlocListener<UserAddBloc, UserAddState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading ||
          previous.isUserSelected != current.isUserSelected,
      listener: _blocListener,
      child: Scaffold(
        appBar: const AppBarPrimary(
          leftButton: AppBarPrimaryBackButton()
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30.w, 22.h, 30.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBarSecondary(title: 'Add User'),
              SizedBox(height: 26.h),
              BlocSelector<UserAddBloc, UserAddState, bool>(
                selector: (state) => state.isSearchBarEmpty,
                builder: (_, isSearchBarEmpty) =>
                  SearchBarTextField(
                    hintText: 'Search for users',
                    controller: bloc.searchBarController,
                    showClearButton: !isSearchBarEmpty,
                    onClearPressed: () =>
                      _clearSearchBarPressed(bloc),
                    onChanged: () =>
                      _onSearchBarChanged(bloc),
                    onChangedWithDelay: () =>
                      _onSearchBarChangedWithDelay(bloc)
                  )
              ),
              BlocSelector<UserAddBloc, UserAddState, List<User>>(
                selector: (state) => state.users,
                builder: (_, users) =>
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, index) =>
                        Container(
                          margin: EdgeInsets.only(bottom: 26.h),
                          child: AppListTile(
                            leading: CircleAvatar(
                              radius: 25.r,
                              backgroundColor: AppColors.blue,
                              backgroundImage: NetworkImage(users[index].imageUrl)
                            ),
                            title: users[index].name,
                            onPressed: () => _userPressed(users[index].id, bloc)
                          )
                        )
                    )
                  )
              )
            ]
          )
        )
      )
    );
  }
}