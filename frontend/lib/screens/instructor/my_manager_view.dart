import 'package:fitman_app/models/user_front.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для получения менеджера, назначенного инструктору
final assignedManagerProvider = FutureProvider.family<User, int>((
  ref,
  instructorId,
) async {
  return ApiService.getAssignedManagerForInstructor(instructorId);
});

class MyManagerView extends ConsumerWidget {
  final int instructorId;
  const MyManagerView({super.key, required this.instructorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managerAsyncValue = ref.watch(assignedManagerProvider(instructorId));

    return managerAsyncValue.when(
      data: (manager) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.manage_accounts, size: 64),
              const SizedBox(height: 16),
              Text(
                manager.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(manager.email),
              // TODO: Add chat frame
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Ошибка загрузки менеджера: $error')),
    );
  }
}
