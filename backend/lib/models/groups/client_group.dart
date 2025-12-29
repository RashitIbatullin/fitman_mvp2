import 'client_group_type.dart';

class GroupCondition {
  GroupCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final String operator;
  final String value;
}

class ClientGroup {
  ClientGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.conditions,
    required this.clientIds,
    required this.isAutoUpdate,
  });

  final String id;
  final String name;
  final ClientGroupType type;
  final String description;
  final List<GroupCondition> conditions; // Условия попадания в группу
  final List<String> clientIds;         // Участники группы
  final bool isAutoUpdate;              // Автоматическое обновление состава
}
