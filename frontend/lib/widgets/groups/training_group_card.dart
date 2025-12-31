import 'package:flutter/material.dart';
import 'package:fitman_app/models/groups/training_group.dart';
import 'package:intl/intl.dart';

class TrainingGroupCard extends StatelessWidget {
  final TrainingGroup group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TrainingGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (group.description != null && group.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    group.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8.0),
              _buildInfoRow(context, Icons.person, 'Тренер:', group.primaryTrainerId),
              _buildInfoRow(context, Icons.people, 'Участники:', '${group.currentParticipants}/${group.maxParticipants}'),
              _buildInfoRow(context, Icons.calendar_today, 'Начало:', DateFormat('dd.MM.yyyy').format(group.startDate)),
              if (group.endDate != null)
                _buildInfoRow(context, Icons.calendar_today, 'Окончание:', DateFormat('dd.MM.yyyy').format(group.endDate!)),
              _buildInfoRow(context, Icons.check_circle, 'Активна:', group.isActive ? 'Да' : 'Нет'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}