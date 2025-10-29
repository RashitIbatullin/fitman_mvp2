import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_front.dart';
import '../models/role.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  final User user;
  const RoleSelectionScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите роль для сессии'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: ListView.builder(
        itemCount: user.roles.length,
        itemBuilder: (context, index) {
          final role = user.roles[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(role.title),
              onTap: () {
                // Устанавливаем выбранную роль и позволяем AuthWrapper перенаправить
                ref.read(authProvider.notifier).setSelectedRole(role);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: () {
            ref.read(authProvider.notifier).logout();
          },
          child: const Text('Выйти'),
        ),
      ),
    );
  }
}
