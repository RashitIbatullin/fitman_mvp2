import 'package:flutter/material.dart';
import '../../../models/groups/client_group.dart';
import '../../../widgets/groups/group_type_badge.dart'; // To display group type visually

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  final ClientGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      group.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              GroupTypeBadge(type: group.type), // Display group type
              if (group.isAutoUpdate) ...[
                const SizedBox(width: 4.0),
                const Icon(Icons.autorenew, size: 18.0, color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
