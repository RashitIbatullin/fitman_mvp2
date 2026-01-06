import 'package:fitman_app/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/groups/training_groups_provider.dart';
import 'package:fitman_app/screens/admin/groups/training_group_edit_screen.dart';
import 'package:fitman_app/widgets/groups/training_group_card.dart';

class TrainingGroupsScreen extends ConsumerStatefulWidget {
  const TrainingGroupsScreen({super.key});

  @override
  ConsumerState<TrainingGroupsScreen> createState() => _TrainingGroupsScreenState();
}

class _TrainingGroupsScreenState extends ConsumerState<TrainingGroupsScreen> {
  String _searchQuery = '';
  int? _selectedGroupTypeId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(usersProvider.notifier).fetchUsers();
      // Ensure group types are also fetched if not already available
      ref.read(trainingGroupTypesProvider);
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainingGroupsAsyncValue = ref.watch(trainingGroupsProvider);
    final groupTypesAsyncValue = ref.watch(trainingGroupTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировочные группы'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по названию',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          groupTypesAsyncValue.when(
            data: (types) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Все'),
                    selected: _selectedGroupTypeId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGroupTypeId = null;
                      });
                    },
                  ),
                  ...types.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(type.title),
                        selected: _selectedGroupTypeId == type.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGroupTypeId = selected ? type.id : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => Center(child: Text('Ошибка загрузки типов: $e')),
          ),
          const Divider(),
          Expanded(
            child: trainingGroupsAsyncValue.when(
              data: (groups) {
                final filteredGroups = groups.where((group) {
                  final nameMatches = group.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final typeMatches = _selectedGroupTypeId == null || group.trainingGroupTypeId == _selectedGroupTypeId;
                  return nameMatches && typeMatches;
                }).toList();

                if (filteredGroups.isEmpty) {
                  return const Center(child: Text('Нет групп, соответствующих фильтру.'));
                }
                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return TrainingGroupCard(
                      group: group,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TrainingGroupEditScreen(groupId: group.id?.toString()),
                          ),
                        );
                        // Refresh the list after editing
                        ref.invalidate(trainingGroupsProvider);
                      },
                      onDelete: () async {
                        if (group.id == null) return;
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
                          await ref.read(trainingGroupsProvider.notifier).deleteTrainingGroup(group.id!);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TrainingGroupEditScreen(),
            ),
          );
          // Refresh the list after creating
          ref.invalidate(trainingGroupsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}