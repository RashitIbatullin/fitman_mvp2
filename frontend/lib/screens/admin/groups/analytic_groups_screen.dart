import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/groups/analytic_groups_provider.dart';
import 'package:fitman_app/screens/admin/groups/analytic_group_edit_screen.dart';
import 'package:fitman_app/widgets/groups/analytic_group_card.dart';

class AnalyticGroupsScreen extends ConsumerWidget {
  const AnalyticGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticGroupsAsyncValue = ref.watch(analyticGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитические группы'),
      ),
      body: analyticGroupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Нет аналитических групп.'));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return AnalyticGroupCard(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AnalyticGroupEditScreen(groupId: group.id),
                    ),
                  );
                },
                onDelete: () async {
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
                    ref.read(analyticGroupsProvider.notifier).deleteAnalyticGroup(group.id);
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
              builder: (context) => const AnalyticGroupEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}