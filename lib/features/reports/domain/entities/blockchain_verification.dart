import 'package:equatable/equatable.dart';

/// Represents a single audit entry from the blockchain.
class BlockchainAuditEntry extends Equatable {
  final String reportId;
  final int actionType;
  final String actor;
  final int timestamp;
  final String detailsHash;
  final String oldStatus;
  final String newStatus;

  const BlockchainAuditEntry({
    required this.reportId,
    required this.actionType,
    required this.actor,
    required this.timestamp,
    required this.detailsHash,
    required this.oldStatus,
    required this.newStatus,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  List<Object?> get props => [
    reportId,
    actionType,
    actor,
    timestamp,
    detailsHash,
    oldStatus,
    newStatus,
  ];
}

/// Represents the result of a blockchain verification check.
class BlockchainVerificationResult extends Equatable {
  final String reportId;
  final String? onChainId;
  final bool verified;
  /// Null for v4 checkpoints because workflow status remains off-chain.
  final bool? statusVerified;
  final Map<String, dynamic> blockchainData;
  final List<BlockchainAuditEntry> auditHistory;
  final String message;

  /// True if the on-chain record was not found (contract reset/redeployed).
  /// This is NOT an integrity breach — it is a blockchain reset event.
  final bool notFoundOnChain;

  /// True if the blockchain RPC endpoint could not be reached.
  final bool connectionError;

  /// False if the report has never been anchored to the blockchain.
  final bool isAnchored;

  const BlockchainVerificationResult({
    required this.reportId,
    this.onChainId,
    required this.verified,
    this.statusVerified,
    required this.blockchainData,
    required this.auditHistory,
    required this.message,
    this.notFoundOnChain = false,
    this.connectionError = false,
    this.isAnchored = true,
  });

  @override
  List<Object?> get props => [
    reportId,
    onChainId,
    verified,
    statusVerified,
    blockchainData,
    auditHistory,
    message,
    notFoundOnChain,
    connectionError,
    isAnchored,
  ];
}

/// Maps the integer `action_type` emitted by AuditTrail.sol events.
///
/// Must stay in sync with:
///   - `BLOCKCHAIN_ACTION_*` constants in
///     `BayanTrack-Backend/backend/reports/workflow_views.py`
///   - `BLOCKCHAIN_ACTION_LABELS` in
///     `BayanTrack-Web/src/domains/reports/constants.ts`
enum AuditActionType {
  /// action_type = 0: Initial report submission and blockchain anchor.
  reportSubmitted,

  /// action_type = 1: Report assigned to a department or endorsed.
  reportAssigned,

  /// action_type = 2: Generic status update (acknowledge, escalate, etc.).
  statusUpdated,

  /// action_type = 3: Report resolved at the barangay level.
  reportResolved,

  /// action_type = 4: Resolution verified by municipal/superadmin.
  reportVerified,

  /// action_type = 5: A staff note was added to the report.
  noteAdded,

  /// action_type = 6: An AI triage or classification decision was recorded.
  aiDecisionRecorded;

  /// Convert a raw integer from the blockchain event into an [AuditActionType].
  ///
  /// Unknown future values safely fall back to [statusUpdated] so that
  /// "Unknown Action" can never appear in the UI.
  static AuditActionType fromInt(int value) => switch (value) {
        0 => AuditActionType.reportSubmitted,
        1 => AuditActionType.reportAssigned,
        2 => AuditActionType.statusUpdated,
        3 => AuditActionType.reportResolved,
        4 => AuditActionType.reportVerified,
        5 => AuditActionType.noteAdded,
        6 => AuditActionType.aiDecisionRecorded,
        _ => AuditActionType.statusUpdated, // safe, forward-compatible fallback
      };

  /// Human-readable label for display in the audit trail UI.
  String get displayLabel => switch (this) {
        AuditActionType.reportSubmitted => 'Report Submitted',
        AuditActionType.reportAssigned => 'Report Assigned',
        AuditActionType.statusUpdated => 'Status Updated',
        AuditActionType.reportResolved => 'Report Resolved',
        AuditActionType.reportVerified => 'Report Verified',
        AuditActionType.noteAdded => 'Note Added',
        AuditActionType.aiDecisionRecorded => 'AI Decision Recorded',
      };
}
