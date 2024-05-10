import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_firebase_chat/src/models/chat_model.dart';
import 'package:flutter_firebase_chat/src/models/user_model.dart';
import 'package:flutter_firebase_chat/src/models/message_model.dart';
import 'package:flutter_firebase_chat/src/app_colors.dart';
import 'package:flutter_firebase_chat/src/widgets/loader.dart';
import 'package:flutter_firebase_chat/src/widgets/app_icon_button.dart';
import 'package:flutter_firebase_chat/src/widgets/app_bar_primary.dart';
import 'package:flutter_firebase_chat/src/widgets/image_view.dart';
import 'package:flutter_firebase_chat/src/screens/user_add/user_add.dart';
import 'package:flutter_firebase_chat/src/screens/video_call/video_call.dart';
import 'chat_detail_bloc.dart';

final class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  void _fetchNextMessages(ChatDetailBloc bloc) {
    bloc.add(ChatDetailMessagesFetchedEvent());
  }

  void _onTextChanged(ChatDetailBloc bloc) {
    bloc.add(ChatDetailTextChangedEvent());
  }

  void _sendTextPressed(ChatDetailBloc bloc) {
    bloc.add(ChatDetailSendTextEvent());
  }

  void _sendImagePressed(
    BuildContext context,
    ChatDetailBloc bloc
  ) {
    showAdaptiveActionSheet(
      context: context,
      actions: [
        BottomSheetAction(
          title: const Text('Take Photo'),
          onPressed: (_) {
            bloc.add(ChatDetailSendImageFromCameraEvent());
            Navigator.pop(context);
          }
        ),
        BottomSheetAction(
          title: const Text('Photo from Library'),
          onPressed: (_) {
            bloc.add(ChaDetailtSendImageFromLibraryEvent());
            Navigator.pop(context);
          }
        )
      ],
      cancelAction: CancelAction(title: const Text('Cancel'))
    );
  }

  void _addUserPressed(
    BuildContext context,
    ChatDetailBloc bloc
  ) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        BlocProvider<UserAddBloc>(
          create: (_) => UserAddBloc(bloc.state.chat!),
          child: const UserAddScreen()
        )
      )
    );
  }

  Future<bool> _isPermissionGranted() async {
    List<PermissionStatus> statuses = (await [
      Permission.camera,
      Permission.microphone
    ].request()).values.toList();
    return !statuses.any((status) => !status.isGranted);
  }

  void _videoCallPressed(
    BuildContext context,
    ChatDetailBloc bloc
  ) async {
    if (await _isPermissionGranted()) {
      // ignore: use_build_context_synchronously
      Navigator.push(context,
        MaterialPageRoute(builder: (_) =>
          BlocProvider<VideoCallBloc>(
            create: (_) => VideoCallBloc(bloc.state.chat!.id),
            child: const VideoCallScreen()
          )
        )
      );
    }
  }

  void _blocListener(
    BuildContext context,
    ChatDetailState state
  ) {
    state.isLoading ?
      Loader.open(context) :
      Loader.close(context);
  }

  @override
  Widget build(BuildContext context) {
    ChatDetailBloc bloc = BlocProvider.of<ChatDetailBloc>(context);
    bloc.add(ChatDetailInitializedEvent());
    return BlocListener<ChatDetailBloc, ChatDetailState>(
      listenWhen: (previous, current) => 
        previous.isLoading != current.isLoading,
      listener: _blocListener,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBarPrimary.preferredSizeHeight),
          child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
            builder: (_, state) =>
              _AppNavBarBuilder(
                chat: state.chat,
                user: state.user,
                onBackPressed: () => Navigator.pop(context),
                onAddUserPressed: () => _addUserPressed(context, bloc),
                onVideoCallPressed: () => _videoCallPressed(context, bloc)
              )
          )
        ),
        body: Column(
          children: [
            BlocBuilder<ChatDetailBloc, ChatDetailState>(
              builder: (_, state) =>
                _MessageListBuilder(
                  messages: state.messages,
                  chat: state.chat,
                  scrollController: bloc.scrollController,
                  fetchNextMessages: () => _fetchNextMessages(bloc)
                )
            ),
            BlocSelector<ChatDetailBloc, ChatDetailState, bool>(
              selector: (state) => state.isTextValid,
              builder: (_, isTextValid) =>
                _BottomBarBuilder(
                  isTextValid: isTextValid,
                  textController: bloc.textController,
                  onTextChanged: () => _onTextChanged(bloc),
                  onSendTextPressed: () => _sendTextPressed(bloc),
                  onSendImagePressed: () => _sendImagePressed(context, bloc)
                )
            )
          ]
        )
      )
    );
  }
}

final class _AppNavBarBuilder extends StatelessWidget {
  final Chat? chat;
  final User? user;
  final Function() onBackPressed;
  final Function() onAddUserPressed;
  final Function() onVideoCallPressed;

  const _AppNavBarBuilder({
    required this.chat,
    required this.user,
    required this.onBackPressed,
    required this.onAddUserPressed,
    required this.onVideoCallPressed
  });

  @override
  Widget build(BuildContext context) {
    return AppBarPrimary(
      leftButton: AppIconButton(
        height: AppBarPrimary.preferredSizeHeight,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.black,
          size: 25.r
        ),
        onPressed: onBackPressed
      ),
      title: AppBarPrimaryTitle(
        (chat != null) ? chat!.name :
          (user != null) ? user!.name : ''
      ),
      rightButtons: [
        SizedBox(width: 22.5.w),
        (chat != null && chat!.members.length <= 5) ?
          AppIconButton(
            height: AppBarPrimary.preferredSizeHeight,
            padding: EdgeInsets.symmetric(horizontal: 7.5.w),
            icon: Icon(
              Icons.person_add,
              color: AppColors.black,
              size: 25.r
            ),
            onPressed: onAddUserPressed
          ) :
          Container(),
        (chat != null && chat!.members.length == 2) ?
          AppIconButton(
            height: AppBarPrimary.preferredSizeHeight,
            padding: EdgeInsets.symmetric(horizontal: 7.5.w),
            icon: Icon(
              Icons.video_call,
              color: AppColors.black,
              size: 33.r
            ),
            onPressed: onVideoCallPressed
          ) :
          Container(),
        SizedBox(width: 22.5.w)
      ],
      border: const Border(
        bottom: BorderSide(
          color: AppColors.lightGrey,
          width: 0.5
        )
      )
    );
  }
}

final class _MessageListBuilder extends StatelessWidget {
  final List<Message> messages;
  final Chat? chat;
  final ScrollController scrollController;
  final Function() fetchNextMessages;

  const _MessageListBuilder({
    required this.messages,
    required this.chat, 
    required this.scrollController,
    required this.fetchNextMessages 
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        reverse: true,
        padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 20.h),
        controller: scrollController,
        itemCount: messages.length + 1,
        itemBuilder: (_, index) {
          if (index < messages.length) {
            bool showTopMessagePart = (index == messages.length - 1) || ((index < messages.length - 1) &&
              (messages[index].userId != messages[index + 1].userId));
            bool showUserNameAndImageUrl = (chat!.members.length > 2 &&
              messages[index].userId != null);
            return _MessageItemBuilder(
              content: messages[index].content,
              contentType: messages[index].contentType,
              date: showTopMessagePart ? messages[index].date : null,
              userId: messages[index].userId,
              userName: (showTopMessagePart && showUserNameAndImageUrl) ?
                chat!.members[messages[index].userId]['username'] :
                null,
              userImageUrl: (showTopMessagePart && showUserNameAndImageUrl) ?
                chat!.members[messages[index].userId]['imageUrl'] :
                null,
              withoutTopBorders: (index < messages.length - 1) &&
                (messages[index].userId == messages[index + 1].userId),
              withoutBottomBorders: (index > 0) &&
                (messages[index].userId == messages[index - 1].userId),
              withLeftOffset: showUserNameAndImageUrl
            );
          }
          else {
            return (messages.isNotEmpty && messages.last.docSnapshot != null) ?
              VisibilityDetector(
                key: Key('${UniqueKey().toString()}_loader_key'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction > 0) {
                    fetchNextMessages();
                  }
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(12.r),
                    height: 25.r,
                    width: 25.r,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                      strokeWidth: 3.r
                    )
                  )
                )
              ) :
              Container();
          }
        }
      )
    );
  }
}

final class _MessageItemBuilder extends StatelessWidget {
  final String content;
  final String contentType;
  final String? date;
  final String? userId;
  final String? userName;
  final String? userImageUrl;
  final bool withoutTopBorders;
  final bool withoutBottomBorders;
  final bool withLeftOffset;

  const _MessageItemBuilder({
    required this.content,
    required this.contentType,
    required this.date,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.withoutTopBorders,
    required this.withoutBottomBorders,
    required this.withLeftOffset
  });

  @override
  Widget build(BuildContext context) {
    bool isCurrent = (userId == null);
    BorderRadius bubbleBorderRadius = BorderRadius.only(
      topLeft: withoutTopBorders ?
        (isCurrent ? Radius.circular(10.r) : Radius.zero) :
        Radius.circular(10.r),
      topRight: withoutTopBorders ?
        (isCurrent ? Radius.zero : Radius.circular(10.r)) :
        Radius.circular(10.r),
      bottomLeft: withoutBottomBorders ?
        (isCurrent ? Radius.circular(10.r) : Radius.zero) :
        Radius.circular(10.r),
      bottomRight: withoutBottomBorders ?
        (isCurrent ? Radius.zero : Radius.circular(10.r)) :
        Radius.circular(10.r)
    );
    double bubbleMaxWidth = (MediaQuery.of(context).size.width - 60.r) * 0.7;
    if (withLeftOffset) {
      bubbleMaxWidth = bubbleMaxWidth - 50.r;
    }
    return Column(
      children: [
        (date != null) ?
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.r),
            child: Text(
              date!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey
              )
            )
          ) :
          Container(),
        Row(
          mainAxisAlignment: isCurrent ?
            MainAxisAlignment.end :
            MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (userImageUrl != null) ?
              Container(
                margin: EdgeInsets.only(right: 10.r),
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.blue,
                  backgroundImage: NetworkImage(userImageUrl!)
                )
              ) : 
              withLeftOffset ?
                SizedBox(
                  width: 50.r,
                  height: 50.r
                ) :
                Container(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (userName != null) ?
                  Container(
                    margin: EdgeInsets.only(bottom: 8.r),
                    child: Text(
                      userName!,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.grey
                      )
                    )
                  ) :
                  Container(),
                Container(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  decoration: BoxDecoration(
                    color: (contentType == 'image') ?
                      Colors.transparent :
                      isCurrent ?
                        AppColors.blue :
                        AppColors.lightGrey,
                    borderRadius: bubbleBorderRadius
                  ),
                  padding: (contentType == 'image') ?
                    EdgeInsets.zero :
                    EdgeInsets.symmetric(
                      horizontal: 10.r,
                      vertical: 8.r
                    ),
                  margin: EdgeInsets.only(bottom: 8.r),
                  child: (contentType == 'image') ?
                    GestureDetector(
                      onTap: () =>
                        Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            ImageView(content)
                          )
                        ),
                      child: ClipRRect(
                        borderRadius: bubbleBorderRadius,
                        child: Image.network(
                          content,
                          fit: BoxFit.fitHeight,
                          height: bubbleMaxWidth - 50.r,
                        )
                      )
                    ) :
                    Text(
                      content,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isCurrent ?
                          AppColors.white :
                          AppColors.black
                      )
                    )
                )
              ]
            )
          ]
        )
      ]
    );
  }
}

final class _BottomBarBuilder extends StatelessWidget {
  final bool isTextValid;
  final TextEditingController textController;
  final Function() onTextChanged;
  final Function() onSendTextPressed;
  final Function() onSendImagePressed;

  const _BottomBarBuilder({
    required this.isTextValid,
    required this.textController,
    required this.onTextChanged,
    required this.onSendTextPressed,
    required this.onSendImagePressed
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(15.w, 0, 30.w, 5.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconButton(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 5.h
              ),
              icon: Icon(
                Icons.add_a_photo,
                color: AppColors.black,
                size: 25.h
              ),
              onPressed: onSendImagePressed
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15.w,
                  right: 5.w
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: AppColors.lightGrey)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 16.h,
                          color: AppColors.black
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter message...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h)
                        ),
                        maxLines: null,
                        controller: textController,
                        onChanged: (_) => onTextChanged()
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5.h),
                      child: AppIconButton(
                        height: 25.h,
                        width: 25.h,
                        backgroundColor: isTextValid ?
                          AppColors.blue : AppColors.lightGrey,
                        shape: const CircleBorder(),
                        icon: Icon(
                          Icons.arrow_upward,
                          size: 18.h,
                          color: AppColors.white
                        ),
                        onPressed: isTextValid ?
                          onSendTextPressed : null
                      )
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }
}