import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/groups/client_groups_provider.dart';
import '../../shared/groups/groups_list_view.dart'; // Re-using the shared list view
import '../../../models/groups/client_group.dart';
import '../../../models/groups/group_types.dart';
import 'group_edit_screen.dart'; // For editing/creating groups

class ClientGroupsScreen extends ConsumerWidget {
  const ClientGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientGroupsState = ref.watch(clientGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы клиентов (Администратор)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(clientGroupsProvider.notifier).fetchGroups();
            },
          ),
        ],
      ),
      body: clientGroupsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : clientGroupsState.error != null
              ? Center(child: Text('Ошибка: ${clientGroupsState.error}'))
              : GroupsListView(
                  groups: clientGroupsState.groups,
                  onTap: (group) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupEditScreen(group: group),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a new screen/dialog for creating a new group
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupEditScreen(group: ClientGroup(
                id: 0, // Placeholder for new group, will be ignored by backend create
                name: '',
                type: ClientGroupType.custom, // Default to custom
                description: '',
                isAutoUpdate: false,
              )),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
