import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat/chat_models.dart';
import '../services/api_service.dart';

@immutable
class ChatState {
  final List<Chat> chats;
  final Map<int, List<Message>> messages;
  final int? activeChatId;
  final bool isLoading;
  final String? error;
  final WebSocketChannel? webSocketChannel;

  const ChatState({
    this.chats = const [],
    this.messages = const {},
    this.activeChatId,
    this.isLoading = false,
    this.error,
    this.webSocketChannel,
  });

  ChatState copyWith({
    List<Chat>? chats,
    Map<int, List<Message>>? messages,
    int? activeChatId,
    bool? isLoading,
    String? error,
    WebSocketChannel? webSocketChannel,
    bool clearActiveChatId = false,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      activeChatId: clearActiveChatId ? null : activeChatId ?? this.activeChatId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      webSocketChannel: webSocketChannel ?? this.webSocketChannel,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    ref.onDispose(() {
      state.webSocketChannel?.sink.close();
    });
    return const ChatState();
  }

  Future<void> connect() async {
    if (state.webSocketChannel != null && state.webSocketChannel!.closeCode == null) return;

    final token = ApiService.currentToken;
    if (token == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }
    
    final wsUrl = Uri.parse('${ApiService.baseUrl.replaceFirst('http', 'ws')}/api/chat/ws?token=$token');
    
    try {
      final channel = WebSocketChannel.connect(wsUrl);
      state = state.copyWith(webSocketChannel: channel);

      channel.stream.listen(
        (data) {
          final message = Message.fromJson(jsonDecode(data));
          _addMessage(message);
        },
        onError: (error) => state = state.copyWith(error: error.toString(), webSocketChannel: null),
        onDone: () => state = state.copyWith(webSocketChannel: null),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void disconnect() {
    state.webSocketChannel?.sink.close();
    state = state.copyWith(webSocketChannel: null);
  }

  Future<void> fetchChats() async {
    try {
      state = state.copyWith(isLoading: true);
      final chats = await ApiService.getChats();
      state = state.copyWith(chats: chats, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> setActiveChat(int chatId) async {
    state = state.copyWith(activeChatId: chatId, isLoading: true, error: null);
    try {
      final messages = await ApiService.getMessages(chatId);
      final currentMessages = Map<int, List<Message>>.from(state.messages);
      currentMessages[chatId] = messages;
      state = state.copyWith(messages: currentMessages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<int> openPrivateChat(int peerId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final chatId = await ApiService.createOrGetPrivateChat(peerId);
      await setActiveChat(chatId);
      return chatId;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  void sendMessage(String content) {
    if (state.activeChatId == null || state.webSocketChannel == null) return;
    
    final message = {
      'chat_id': state.activeChatId,
      'content': content,
    };

    state.webSocketChannel!.sink.add(jsonEncode(message));
  }
  
  void _addMessage(Message message) {
    final currentMessages = Map<int, List<Message>>.from(state.messages);
    final chatMessages = List<Message>.from(currentMessages[message.chatId] ?? []);
    
    if (!chatMessages.any((m) => m.id == message.id)) {
        chatMessages.insert(0, message);
        currentMessages[message.chatId] = chatMessages;
        state = state.copyWith(messages: currentMessages);
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
