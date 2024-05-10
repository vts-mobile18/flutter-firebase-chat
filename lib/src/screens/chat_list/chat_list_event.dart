part of 'chat_list_bloc.dart';

abstract base class ChatListEvent {}

final class ChatListInitializedEvent extends ChatListEvent {}

final class ChatListSearchBarShownEvent extends ChatListEvent {}

final class ChatListSearchBarChangedEvent extends ChatListEvent {}

final class ChatListItemsChangedEvent extends ChatListEvent {
  final (List<Chat>, List<User>)? chatsUsers;
  ChatListItemsChangedEvent([this.chatsUsers]);
}

final class ChatListItemRemovedEvent extends ChatListEvent {
  final String id;
  ChatListItemRemovedEvent(this.id);
}