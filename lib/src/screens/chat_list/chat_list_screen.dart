import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/search_bar_text_field.dart';
import 'package:flutter_firebase_chat/src/widgets/app_list_tile.dart';
import 'package:flutter_firebase_chat/src/widgets/confirm_alert.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_secondary.dart';
import 'package:flutter_firebase_chat/src/screens/chat_detail/chat_detail.dart';
import 'chat_list_bloc.dart';

final class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

final class ChatListScreenState extends State<ChatListScreen> with AutomaticKeepAliveClientMixin<ChatListScreen> {
  late ChatListBloc _bloc;

  void _showSearchBarPressed() {
    _bloc.add(ChatListSearchBarShownEvent());
  }

  void _onSearchBarChanged() {
    _bloc.add(ChatListSearchBarChangedEvent());
  }

  void _onSearchBarChangedWithDelay() {
    _bloc.add(ChatListItemsChangedEvent());
  }

  void _clearSearchBarPressed() {
    _bloc.searchBarController.text = '';
    _onSearchBarChanged();
    _bloc.add(ChatListItemsChangedEvent());
  }

  void _chatOrUserPressed(dynamic chatOrUser) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        BlocProvider<ChatDetailBloc>(
          create: (_) => ChatDetailBloc(chatOrUser),
          child: const ChatDetailScreen()
        )
      )
    );
    _clearSearchBarPressed();
  }

  void _chatRemovePressed(String chatId) {
    ConfirmAlert.open(
      context: context,
      title: 'Are you sure you want to delete this chat?',
      onConfirm: () =>
        _bloc.add(ChatListItemRemovedEvent(chatId))
    );
  }

  void _blocListener(
    BuildContext context,
    ChatListState state
  ) {
    state.isLoading ?
      Loader.open(context) :
      Loader.close(context);
  }

  @override
  void initState() {
    _bloc = BlocProvider.of<ChatListBloc>(context);
    _bloc.add(ChatListInitializedEvent());
    super.initState();
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<ChatListBloc, ChatListState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading,
      listener: _blocListener,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
            child: Column(
              children: [
                AppBarSecondary(
                  title: 'Chats',
                  buttonIconData: Icons.search,
                  onButtonPressed: _showSearchBarPressed
                ),
                BlocSelector<ChatListBloc, ChatListState, bool>(
                  selector: (state) => state.isSearchBarShown,
                  builder: (_, isSearchBarShown) =>
                    Column(
                      children: [
                        SizedBox(height: isSearchBarShown ? 26.h : 34.h),
                        isSearchBarShown ?
                          BlocSelector<ChatListBloc, ChatListState, bool>(
                            selector: (state) => state.isSearchBarEmpty,
                            builder: (_, isSearchBarEmpty) =>
                              SearchBarTextField(
                                hintText: 'Search for chats and users',
                                controller: _bloc.searchBarController,
                                showClearButton: !isSearchBarEmpty,
                                onClearPressed: _clearSearchBarPressed,
                                onChanged: _onSearchBarChanged,
                                onChangedWithDelay: _onSearchBarChangedWithDelay
                              )
                          ) :
                          Container()
                      ]
                    )
                ),
                BlocSelector<ChatListBloc, ChatListState, (List<Chat>, List<User>)>(
                  selector: (state) => state.chatsUsers,
                  builder: (_, chatsUsers) =>
                    _ChatsAndUsersListBuilder(
                      chatsUsers: chatsUsers,
                      onChatOrUserPressed: _chatOrUserPressed,
                      onChatRemovePressed: _chatRemovePressed
                    )
                )
              ]
            )
          )
        )
      )
    );
  }
}

final class _ChatsAndUsersListBuilder extends StatelessWidget {
  final (List<Chat>, List<User>) chatsUsers;
  final Function(dynamic) onChatOrUserPressed;
  final Function(String) onChatRemovePressed;

  const _ChatsAndUsersListBuilder({
    required this.chatsUsers,
    required this.onChatOrUserPressed,
    required this.onChatRemovePressed
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          (chatsUsers.$1.isNotEmpty && chatsUsers.$2.isNotEmpty) ?
            const _HeaderItemBuilder('Chats') :
            Container(),
          ...chatsUsers.$1.map((chat) =>
            _ChatItemBuilder(
              chat: chat,
              onPressed: () =>
                onChatOrUserPressed(chat),
              onRemovePressed: () =>
                onChatRemovePressed(chat.id)
            )
          ).toList(),
          chatsUsers.$2.isNotEmpty ?
            const _HeaderItemBuilder('Users') :
            Container(),
          ...chatsUsers.$2.map((user) =>
            _UserItemBuilder(
              user: user,
              onPressed: () =>
                onChatOrUserPressed(user)
            )
          ).toList()
        ]
      )
    );
  }
}

final class _HeaderItemBuilder extends StatelessWidget {
  final String text;
  const _HeaderItemBuilder(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey
        )
      )
    );
  }
}

final class _ChatItemBuilder extends StatelessWidget {
  final Chat chat;
  final Function() onPressed;
  final Function() onRemovePressed;

  const _ChatItemBuilder({
    required this.chat,
    required this.onPressed,
    required this.onRemovePressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      child: Slidable(
        key: ValueKey(chat.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              icon: Icons.delete_outline,
              onPressed: (context) {
                Slidable.of(context)?.close();
                onRemovePressed();
              }
            )
          ],
        ),
        child: AppListTile(
          leading: (chat.imageUrls.length > 1) ?
            SizedBox(
              width: 50.r,
              height: 50.r,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 17.r,
                      backgroundColor: AppColors.blue,
                      backgroundImage: NetworkImage(chat.imageUrls[1])
                    )
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 17.r,
                      backgroundColor: AppColors.blue,
                      backgroundImage: NetworkImage(chat.imageUrls[0])
                    )
                  )
                ]
              )
            ) :
            chat.imageUrls[0].isNotEmpty ?
              CircleAvatar(
                radius: 25.r,
                backgroundColor: AppColors.blue,
                backgroundImage: NetworkImage(chat.imageUrls[0])
              ) :
              Container(),
          title: chat.name,
          subTitle: Row(
            children: [
              Flexible(
                child: Text(
                  chat.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey
                  )
                )
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                width: 2.r,
                height: 2.r,
                decoration: const BoxDecoration(
                  color: AppColors.grey,
                  shape: BoxShape.circle
                ),
              ),
              Flexible(
                child: Text(
                  chat.date,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightGrey
                  )
                )
              )
            ]
          ),
          trailing: chat.hasUnreadMessages ? Container(
            width: 10.r,
            height: 10.r,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle
            ),
          ) : null,
          onPressed: onPressed
        )
      )
    );
  }
}

final class _UserItemBuilder extends StatelessWidget {
  final User user;
  final Function() onPressed;

  const _UserItemBuilder({
    required this.user,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      child: AppListTile(
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: AppColors.blue,
          backgroundImage: NetworkImage(user.imageUrl)
        ),
        title: user.name,
        onPressed: onPressed
      )
    );
  }
}