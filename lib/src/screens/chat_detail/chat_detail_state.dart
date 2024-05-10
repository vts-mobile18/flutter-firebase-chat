part of 'chat_detail_bloc.dart';

final class ChatDetailState {
  final bool isTextValid;
  final bool isLoading;
  final Chat? chat;
  final User? user;
  final List<Message> messages;

  ChatDetailState({
    required this.isTextValid,
    required this.isLoading,
    required this.chat,
    required this.user,
    required this.messages
  });

  ChatDetailState.initial() :
    isTextValid = false,
    isLoading = false,
    chat = null,
    user = null,
    messages = [];

  ChatDetailState copyWith({
    bool? isTextValid,
    bool? isLoading,
    Chat? chat,
    User? user,
    List<Message>? messages
  }) =>
    ChatDetailState(
      isTextValid: isTextValid ?? this.isTextValid,
      isLoading: isLoading ?? this.isLoading,
      chat: chat ?? this.chat,
      user: user ?? this.user,
      messages: messages ?? this.messages
    );
}