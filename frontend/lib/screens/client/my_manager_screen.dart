import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

final managerProvider = FutureProvider<User>((ref) async {
  return ApiService.getManagerForClient();
});

class MyManagerScreen extends ConsumerStatefulWidget {
  const MyManagerScreen({super.key});

  @override
  ConsumerState<MyManagerScreen> createState() => _MyManagerScreenState();
}

class _MyManagerScreenState extends ConsumerState<MyManagerScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final manager = await ref.read(managerProvider.future);
    final chatNotifier = ref.read(chatProvider.notifier);
    
    await chatNotifier.connect();
    await chatNotifier.openPrivateChat(manager.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    ref.read(chatProvider.notifier).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final managerAsyncValue = ref.watch(managerProvider);
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    final currentUser = ref.watch(authProvider).value?.user;

    return managerAsyncValue.when(
      data: (manager) {
        final messages = chatState.activeChatId != null
            ? chatState.messages[chatState.activeChatId] ?? []
            : [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: manager.photoUrl != null
                        ? NetworkImage(manager.photoUrl!)
                        : null,
                    child: manager.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(manager.phone ?? '', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Чат с менеджером', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        if (chatState.isLoading) const LinearProgressIndicator(),
                        Expanded(
                          child: chatState.error != null
                              ? Center(child: Text('Ошибка чата: ${chatState.error}'))
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final isMe = message.senderId == currentUser?.id;
                                    return Align(
                                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Theme.of(context).colorScheme.primaryContainer
                                              : Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: Text(message.content ?? ''),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Введите сообщение...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onSubmitted: (_) => _sendMessage(chatNotifier),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => _sendMessage(chatNotifier),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
    );
  }

  void _sendMessage(ChatNotifier chatNotifier) {
    if (_messageController.text.trim().isNotEmpty) {
      chatNotifier.sendMessage(_messageController.text.trim());
      _messageController.clear();
    }
  }
}
