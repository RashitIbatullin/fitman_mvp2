class GroupSyncLog {
  GroupSyncLog({
    required this.id,
    required this.clientGroupId,
    required this.syncStartedAt,
    required this.syncFinishedAt,
    required this.status,
    required this.details,
  });

  final String id;
  final String clientGroupId;
  final DateTime syncStartedAt;
  final DateTime? syncFinishedAt;
  final String status; // e.g., 'success', 'failed'
  final String details;
}
