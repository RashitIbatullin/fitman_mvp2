import 'package:fitman_app/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/groups/training_groups_provider.dart';
import 'package:fitman_app/screens/admin/groups/training_group_edit_screen.dart';
import 'package:fitman_app/widgets/groups/training_group_card.dart';
import 'package:fitman_app/models/groups/training_group.dart'; // Import for TrainingGroup

class TrainingGroupsScreen extends ConsumerStatefulWidget {
  const TrainingGroupsScreen({super.key});

  @override
  ConsumerState<TrainingGroupsScreen> createState() => _TrainingGroupsScreenState();
}

class _TrainingGroupsScreenState extends ConsumerState<TrainingGroupsScreen> {
  String _searchQuery = '';
  int? _selectedGroupTypeId;
  bool? _isActiveFilter; // null for 'All', true for 'Active', false for 'Inactive'
  bool? _isArchivedFilter; // null for 'All', true for 'Archived', false for 'Not Archived'
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

  // --- Widget Builder Functions ---

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Тренировочные группы'),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Existing Group Type Filter
          ref.watch(trainingGroupTypesProvider).when(
            data: (types) => Row(
              children: [
                ChoiceChip(
                  label: const Text('Все типы'),
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
            loading: () => const SizedBox.shrink(),
            error: (e, st) => Center(child: Text('Ошибка загрузки типов: $e')),
          ),
          const SizedBox(width: 16.0), // Spacer

          ChoiceChip(
            label: const Text('Все (Актив)'),
            selected: _isActiveFilter == null,
            onSelected: (selected) {
              setState(() {
                _isActiveFilter = null;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Активные'),
              selected: _isActiveFilter == true,
              onSelected: (selected) {
                setState(() {
                  _isActiveFilter = selected ? true : null;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Неактивные'),
              selected: _isActiveFilter == false,
              onSelected: (selected) {
                setState(() {
                  _isActiveFilter = selected ? false : null;
                });
              },
            ),
          ),
          const SizedBox(width: 16.0), // Spacer

          ChoiceChip(
            label: const Text('Все (Архив)'),
            selected: _isArchivedFilter == null,
            onSelected: (selected) {
              setState(() {
                _isArchivedFilter = null;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Архивные'),
              selected: _isArchivedFilter == true,
              onSelected: (selected) {
                setState(() {
                  _isArchivedFilter = selected ? true : null;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Неархивные'),
              selected: _isArchivedFilter == false,
              onSelected: (selected) {
                setState(() {
                  _isArchivedFilter = selected ? false : null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(AsyncValue<List<TrainingGroup>> groupsAsyncValue) {
    return Expanded(
      child: groupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Нет групп, соответствующих фильтру.'));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return TrainingGroupCard(
                group: group,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TrainingGroupEditScreen(groupId: group.id?.toString()),
                    ),
                  );
                  // Refresh the list after editing
                  ref.invalidate(trainingGroupsProvider(
                    searchQuery: _searchQuery,
                    groupTypeId: _selectedGroupTypeId,
                    isActive: _isActiveFilter,
                    isArchived: _isArchivedFilter,
                  ));
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
                    await ref.read(trainingGroupsProvider(
                      searchQuery: _searchQuery,
                      groupTypeId: _selectedGroupTypeId,
                      isActive: _isActiveFilter,
                      isArchived: _isArchivedFilter,
                    ).notifier).deleteTrainingGroup(group.id!);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TrainingGroupEditScreen(),
          ),
        );
        // Refresh the list after creating
        ref.invalidate(trainingGroupsProvider(
          searchQuery: _searchQuery,
          groupTypeId: _selectedGroupTypeId,
          isActive: _isActiveFilter,
          isArchived: _isArchivedFilter,
        ));
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainingGroupsAsyncValue = ref.watch(trainingGroupsProvider(
      searchQuery: _searchQuery,
      groupTypeId: _selectedGroupTypeId,
      isActive: _isActiveFilter,
      isArchived: _isArchivedFilter,
    ));

    return Scaffold(
      appBar: _buildAppBar(), // Re-added AppBar
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(),
          _buildGroupList(trainingGroupsAsyncValue),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}