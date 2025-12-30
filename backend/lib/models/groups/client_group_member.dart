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

  factory ClientGroupMember.fromMap(Map<String, dynamic> map) {
    return ClientGroupMember(
      id: map['id'] as int,
      clientGroupId: map['client_group_id'] as int,
      clientId: map['client_id'] as int,
      createdAt: map['created_at'] as DateTime,
      createdBy: map['created_by'] as int?,
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
