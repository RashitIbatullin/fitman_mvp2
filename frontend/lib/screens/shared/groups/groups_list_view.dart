import 'package:flutter/material.dart';
import '../../../models/groups/client_group.dart';
import 'group_card.dart'; // To display individual group cards

class GroupsListView extends StatelessWidget {
  const GroupsListView({
    super.key,
    required this.groups,
    required this.onTap,
  });

  final List<ClientGroup> groups;
  final Function(ClientGroup) onTap;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('Нет групп клиентов.'),
      );
    }
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupCard(
          group: group,
          onTap: () => onTap(group),
        );
      },
    );
  }
}
