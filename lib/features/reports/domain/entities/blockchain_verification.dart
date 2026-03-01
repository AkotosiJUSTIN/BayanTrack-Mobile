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
    required this.statusVerified,
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
