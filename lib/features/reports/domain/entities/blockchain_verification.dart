import 'package:equatable/equatable.dart';

/// Represents a single audit entry from the blockchain.
class BlockchainAuditEntry extends Equatable {
  final int reportId;
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
  final int? onChainId;
  final bool verified;
  final bool statusVerified;
  final Map<String, dynamic> blockchainData;
  final List<BlockchainAuditEntry> auditHistory;
  final String message;

  const BlockchainVerificationResult({
    required this.reportId,
    this.onChainId,
    required this.verified,
    required this.statusVerified,
    required this.blockchainData,
    required this.auditHistory,
    required this.message,
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
  ];
}
