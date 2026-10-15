class SharedIncident {
  const SharedIncident({
    required this.groupId,
    required this.status,
    required this.reportCount,
    this.assignedDepartment,
    this.needsReview = false,
    this.updates = const [],
    this.evidence = const [],
    this.integrityStatus = 'not_recorded',
    this.transactionHash,
  });

  final String groupId;
  final String status;
  final int reportCount;
  final String? assignedDepartment;
  final bool needsReview;
  final List<IncidentUpdate> updates;
  final List<IncidentEvidence> evidence;
  final String integrityStatus;
  final String? transactionHash;
}

class IncidentUpdate {
  const IncidentUpdate({
    required this.id,
    required this.kind,
    required this.message,
    this.createdAt,
  });

  final String id;
  final String kind;
  final String message;
  final DateTime? createdAt;
}

class IncidentEvidence {
  const IncidentEvidence({required this.id, required this.url});

  final String id;
  final String url;
}
