class ClientGroupMember {
  ClientGroupMember({
    required this.id,
    required this.clientGroupId,
    required this.clientId,
    required this.createdAt,
    this.createdBy,
  });

  final int id;
  final int clientGroupId;
  final int clientId;
  final DateTime createdAt;
  final int? createdBy;

  factory ClientGroupMember.fromJson(Map<String, dynamic> json) {
    return ClientGroupMember(
      id: json['id'] as int,
      clientGroupId: json['client_group_id'] as int,
      clientId: json['client_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_group_id': clientGroupId,
      'client_id': clientId,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
