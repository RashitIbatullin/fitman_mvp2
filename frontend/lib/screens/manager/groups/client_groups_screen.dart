import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/groups/client_groups_provider.dart';
import '../../shared/groups/groups_list_view.dart'; // Re-using the shared list view
import '../../admin/groups/group_edit_screen.dart'; // Managers can view group details

class ClientGroupsScreen extends ConsumerWidget {
  const ClientGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientGroupsState = ref.watch(clientGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы клиентов (Менеджер)'),
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
                    // Managers can view group details, perhaps in a read-only form
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupEditScreen(group: group), // Reuse edit screen, can be read-only based on role
                      ),
                    );
                  },
                ),
      // Floating action button for creating new groups might be restricted for managers
      // depending on business rules. For now, it's omitted.
    );
  }
}
