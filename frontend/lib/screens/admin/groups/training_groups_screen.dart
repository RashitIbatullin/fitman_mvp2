import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/groups/training_groups_provider.dart';
import 'package:fitman_app/screens/admin/groups/training_group_edit_screen.dart';
import 'package:fitman_app/widgets/groups/training_group_card.dart';

class TrainingGroupsScreen extends ConsumerWidget {
  const TrainingGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingGroupsAsyncValue = ref.watch(trainingGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировочные группы'),
      ),
      body: trainingGroupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Нет тренировочных групп.'));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return TrainingGroupCard(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TrainingGroupEditScreen(groupId: group.id?.toString()),
                    ),
                  );
                },
                onDelete: () async {
                  if (group.id == null) return; // Should not happen for existing groups
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Подтвердите удаление'),
                      content: Text('Вы уверены, что хотите удалить группу "${group.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    ref.read(trainingGroupsProvider.notifier).deleteTrainingGroup(group.id!);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TrainingGroupEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}