import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

final trainerProvider = FutureProvider<User>((ref) async {
  return ApiService.getTrainerForClient();
});

class MyTrainerScreen extends ConsumerStatefulWidget {
  const MyTrainerScreen({super.key});

  @override
  ConsumerState<MyTrainerScreen> createState() => _MyTrainerScreenState();
}

class _MyTrainerScreenState extends ConsumerState<MyTrainerScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _connectAndLoadChat();
  }

  Future<void> _connectAndLoadChat() async {
    final trainer = await ref.read(trainerProvider.future);
    final chatNotifier = ref.read(chatProvider.notifier);
    
    await chatNotifier.connect(); 

    await chatNotifier.openPrivateChat(trainer.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    ref.read(chatProvider.notifier).disconnect(); // Disconnect WebSocket
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainerData = ref.watch(trainerProvider);
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    final currentUser = ref.watch(authProvider).value?.user; // Get current user

    return trainerData.when(
      data: (trainer) {
        final currentChatMessages = chatState.activeChatId != null
            ? chatState.messages[chatState.activeChatId!] ?? []
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
                    // backgroundImage: NetworkImage(trainer.photoUrl), // TODO: Add photo URL
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.phone ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Чат с тренером',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (chatState.isLoading)
                          const LinearProgressIndicator(),
                        Expanded(
                          child: chatState.error != null
                              ? Center(child: Text('Ошибка чата: ${chatState.error}'))
                              : ListView.builder(
                                  reverse: true, // Display latest messages at the bottom
                                  itemCount: currentChatMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = currentChatMessages[index];
                                    // Correctly identify sender based on authenticated user's ID
                                    final isMe = message.senderId == currentUser?.id; 
                                    return Align(
                                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Text(
                                            '${message.firstName ?? ''} ${message.lastName ?? ''}: ${message.content ?? ''}'
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Введите сообщение...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (_messageController.text.isNotEmpty) {
                                  chatNotifier.sendMessage(_messageController.text);
                                  _messageController.clear();
                                }
                              },
                            ),
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
}

