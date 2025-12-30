import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/groups/client_group.dart';
import '../../../providers/groups/group_members_provider.dart';
import '../../../providers/users_provider.dart';

class ManualGroupEditForm extends ConsumerStatefulWidget {
  final ClientGroup group;
  const ManualGroupEditForm({super.key, required this.group});

  @override
  ConsumerState<ManualGroupEditForm> createState() => _ManualGroupEditFormState();
}

class _ManualGroupEditFormState extends ConsumerState<ManualGroupEditForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch initial data
      ref.read(groupMembersProvider.notifier).fetchMembers(widget.group.id);
      // Fetch all users to resolve names and for the add dialog
      ref.read(usersProvider.notifier).fetchUsers();
    });
  }

  void _showAddClientDialog() {
    final allUsers = ref.read(usersProvider).users;
    final groupMembersState = ref.read(groupMembersProvider);
    final memberClientIds = groupMembersState.members.map((m) => m.clientId).toSet();

    // Filter for users who are clients and not already in the group
    final availableClients = allUsers
        .where((u) =>
            u.roles.any((r) => r.name == 'client') &&
            !memberClientIds.contains(u.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить клиента в группу'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableClients.length,
              itemBuilder: (context, index) {
                final client = availableClients[index];
                return ListTile(
                  title: Text(client.fullName),
                  onTap: () {
                    ref
                        .read(groupMembersProvider.notifier)
                        .addMember(widget.group.id, client.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupMembersState = ref.watch(groupMembersProvider);
    final allUsers = ref.watch(usersProvider).users;

    // Create a map for quick lookup of user names by ID
    final userMap = {for (var user in allUsers) user.id: user};

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Участники группы',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _showAddClientDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (groupMembersState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (groupMembersState.error != null)
              Text('Ошибка: ${groupMembersState.error}', style: const TextStyle(color: Colors.red))
            else if (groupMembersState.members.isEmpty)
              const Center(child: Text('В этой группе пока нет участников.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupMembersState.members.length,
                itemBuilder: (context, index) {
                  final member = groupMembersState.members[index];
                  final user = userMap[member.clientId];
                  return ListTile(
                    title: Text(user?.fullName ?? 'Клиент ID: ${member.clientId}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () {
                        ref
                            .read(groupMembersProvider.notifier)
                            .removeMember(widget.group.id, member.clientId);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}