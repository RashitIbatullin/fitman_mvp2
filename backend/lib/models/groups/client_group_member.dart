class ClientGroupMember {
  ClientGroupMember({
    required this.id,
    required this.clientGroupId,
    required this.clientId,
    required this.joinedAt,
    required this.addedBy,
  });

  final String id;
  final String clientGroupId;
  final String clientId;
  final DateTime joinedAt;
  final String addedBy;
}
