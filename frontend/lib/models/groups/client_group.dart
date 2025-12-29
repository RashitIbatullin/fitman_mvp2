import 'group_types.dart';

class ClientGroup {
  ClientGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.isAutoUpdate,
  });

  final int id;
  final String name;
  final ClientGroupType type;
  final String description;
  final bool isAutoUpdate;

  factory ClientGroup.fromJson(Map<String, dynamic> json) {
    return ClientGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      type: ClientGroupType.values[json['type'] as int], // Convert int back to enum
      description: json['description'] as String,
      isAutoUpdate: json['is_auto_update'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index, // Convert enum to int for JSON
      'description': description,
      'is_auto_update': isAutoUpdate,
    };
  }
}
