import 'package:flutter/material.dart';
import '../../models/groups/group_types.dart'; // Corrected import path

class GroupTypeBadge extends StatelessWidget {
  const GroupTypeBadge({
    super.key,
    required this.type,
  });

  final ClientGroupType type;

  static String getLocalizedTypeName(ClientGroupType type) {
    switch (type) {
      case ClientGroupType.trainingProgram:
        return 'Программа тренировок';
      case ClientGroupType.subscriptionType:
        return 'Тип абонемента';
      case ClientGroupType.corporate:
        return 'Корпоративная';
      case ClientGroupType.demographic:
        return 'Демографическая';
      case ClientGroupType.activityLevel:
        return 'Уровень активности';
      case ClientGroupType.paymentStatus:
        return 'Статус оплаты';
      case ClientGroupType.custom:
        return 'Произвольная';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        getLocalizedTypeName(type),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      backgroundColor: _getBadgeColor(type),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Color _getBadgeColor(ClientGroupType type) {
    switch (type) {
      case ClientGroupType.trainingProgram:
        return Colors.blue.shade700;
      case ClientGroupType.subscriptionType:
        return Colors.green.shade700;
      case ClientGroupType.corporate:
        return Colors.purple.shade700;
      case ClientGroupType.demographic:
        return Colors.orange.shade700;
      case ClientGroupType.activityLevel:
        return Colors.red.shade700;
      case ClientGroupType.paymentStatus:
        return Colors.brown.shade700;
      case ClientGroupType.custom:
        return Colors.grey.shade700;
    }
  }
}
