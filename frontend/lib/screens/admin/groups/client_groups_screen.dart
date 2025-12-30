import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/groups/group_types.dart';
import '../../../providers/groups/client_groups_provider.dart';
import '../../../widgets/groups/group_type_badge.dart';
import '../../shared/groups/groups_list_view.dart';
import 'group_edit_screen.dart';
import '../../../models/groups/client_group.dart'; // Keep this import for ClientGroup creation

class ClientGroupsScreen extends ConsumerStatefulWidget {
  const ClientGroupsScreen({super.key});

  @override
  ConsumerState<ClientGroupsScreen> createState() => _ClientGroupsScreenState();
}

class _ClientGroupsScreenState extends ConsumerState<ClientGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientGroupsProvider.notifier).fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientGroupsState = ref.watch(clientGroupsProvider);
    final filteredGroups = ref.watch(filteredGroupsProvider);

    // Create a set of selected filter types for the SegmentedButton
    final selectedFilter = <ClientGroupType?>{clientGroupsState.filterType};

    return Scaffold( // Re-introducing Scaffold without AppBar
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по названию...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              ),
              onChanged: (query) {
                ref.read(clientGroupsProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<ClientGroupType?>(
                segments: [
                  const ButtonSegment<ClientGroupType?>(
                    value: null,
                    label: Text('Все'),
                  ),
                  ...ClientGroupType.values.map((type) {
                    return ButtonSegment<ClientGroupType?>(
                      value: type,
                      label: Text(GroupTypeBadge.getLocalizedTypeName(type)),
                    );
                  }),
                ],
                selected: selectedFilter,
                onSelectionChanged: (newSelection) {
                  ref.read(clientGroupsProvider.notifier).setFilter(newSelection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: clientGroupsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : clientGroupsState.error != null
                    ? Center(child: Text('Ошибка: ${clientGroupsState.error}'))
                    : GroupsListView(
                        groups: filteredGroups,
                        onTap: (group) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupEditScreen(group: group),
                            ),
                          ).then((_) {
                            // Re-fetch when returning to the list
                            ref.read(clientGroupsProvider.notifier).fetchGroups();
                          });
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupEditScreen(
                group: ClientGroup(
                  id: 0,
                  name: '',
                  type: ClientGroupType.custom,
                  description: '',
                  isAutoUpdate: false,
                ),
              ),
            ),
          ).then((_) {
            // Re-fetch when returning to the list
            ref.read(clientGroupsProvider.notifier).fetchGroups();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

  