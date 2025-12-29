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

  factory GroupCondition.fromMap(Map<String, dynamic> map) {
    return GroupCondition(
      field: map['field'] as String,
      operator: map['operator'] as String,
      value: map['value'] as String,
    );
  }
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

  final int id;
  final String name;
  final ClientGroupType type;
  final String description;
  final List<GroupCondition> conditions; // Условия попадания в группу
  final List<String> clientIds;         // Участники группы
  final bool isAutoUpdate;              // Автоматическое обновление состава

  factory ClientGroup.fromMap(Map<String, dynamic> map) {
    return ClientGroup(
      id: map['id'] as int,
      name: map['name'] as String,
      type: ClientGroupType.values[map['type'] as int],
      description: map['description'] as String,
      isAutoUpdate: map['is_auto_update'] as bool,
      // TODO: Fetch conditions and clientIds from their respective tables
      conditions: [],
      clientIds: [],
    );
  }
}
