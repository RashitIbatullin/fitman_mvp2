import 'group_types.dart';

class ClientGroup {
  ClientGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.clientIds,
    required this.isAutoUpdate,
  });

  final String id;
  final String name;
  final ClientGroupType type;
  final String description;
  final List<String> clientIds;
  final bool isAutoUpdate;

  factory ClientGroup.fromJson(Map<String, dynamic> json) {
    return ClientGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ClientGroupType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'] as String,
      clientIds: List<String>.from(json['clientIds'] as List),
      isAutoUpdate: json['isAutoUpdate'] as bool,
    );
  }
}
