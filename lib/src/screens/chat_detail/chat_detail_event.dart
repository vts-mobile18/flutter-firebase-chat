part of 'chat_detail_bloc.dart';

abstract base class ChatDetailEvent {}

final class ChatDetailInitializedEvent extends ChatDetailEvent {}

final class ChatDetailUpdatedEvent extends ChatDetailEvent {
  final Chat chat;
  ChatDetailUpdatedEvent(this.chat);
}

final class ChatDetailMessagesUpdatedEvent extends ChatDetailEvent {
  final List<Message> messages;
  ChatDetailMessagesUpdatedEvent(this.messages);
}

final class ChatDetailMessagesFetchedEvent extends ChatDetailEvent {}

final class ChatDetailTextChangedEvent extends ChatDetailEvent {}

final class ChatDetailSendTextEvent extends ChatDetailEvent {}

final class ChatDetailSendImageFromCameraEvent extends ChatDetailEvent {}

final class ChaDetailtSendImageFromLibraryEvent extends ChatDetailEvent {}