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

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'operator': operator,
      'value': value,
    };
  }
}

class ClientGroup {
  ClientGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.conditions = const [],
    this.clientIds = const [],
    required this.isAutoUpdate,
  });

  final int id;
  final String name;
  final ClientGroupType type;
  final String description;
  final List<GroupCondition> conditions; // Условия попадания в группу
  final List<int> clientIds; // Участники группы
  final bool isAutoUpdate; // Автоматическое обновление состава

  factory ClientGroup.fromMap(
    Map<String, dynamic> map, {
    List<GroupCondition>? conditions,
    List<int>? clientIds,
  }) {
    return ClientGroup(
      id: map['id'] as int,
      name: map['name'] as String,
      type: ClientGroupType.values[map['type'] as int],
      description: map['description'] as String,
      isAutoUpdate: map['is_auto_update'] as bool,
      conditions: conditions ?? [],
      clientIds: clientIds ?? [],
    );
  }

  // New: toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'is_auto_update': isAutoUpdate,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'clientIds': clientIds,
    };
  }
}
