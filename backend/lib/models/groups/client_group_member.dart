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

  factory ClientGroupMember.fromMap(Map<String, dynamic> map) {
    return ClientGroupMember(
      id: map['id'] as int,
      clientGroupId: map['client_group_id'] as int,
      clientId: map['client_id'] as int,
      joinedAt: map['joined_at'] as DateTime,
      addedBy: map['added_by'] as int,
    );
  }
}
