class ClientGroupMember {
  ClientGroupMember({
    required this.id,
    required this.clientGroupId,
    required this.clientId,
    required this.joinedAt,
    required this.addedBy,
  });

  final int id;
  final int clientGroupId;
  final int clientId;
  final DateTime joinedAt;
  final int addedBy;

  factory ClientGroupMember.fromJson(Map<String, dynamic> json) {
    return ClientGroupMember(
      id: json['id'] as int,
      clientGroupId: json['client_group_id'] as int,
      clientId: json['client_id'] as int,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      addedBy: json['added_by'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_group_id': clientGroupId,
      'client_id': clientId,
      'joined_at': joinedAt.toIso8601String(),
      'added_by': addedBy,
    };
  }
}
