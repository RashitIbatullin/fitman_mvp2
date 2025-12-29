class ClientGroupMember {
  ClientGroupMember({
    required this.id,
    required this.clientGroupId,
    required this.clientId,
    required this.joinedAt,
  });

  final String id;
  final String clientGroupId;
  final String clientId;
  final DateTime joinedAt;

  factory ClientGroupMember.fromJson(Map<String, dynamic> json) {
    return ClientGroupMember(
      id: json['id'] as String,
      clientGroupId: json['clientGroupId'] as String,
      clientId: json['clientId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
