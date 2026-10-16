// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockchain_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlockchainAuditEntryDto _$BlockchainAuditEntryDtoFromJson(
  Map<String, dynamic> json,
) => _BlockchainAuditEntryDto(
  reportId: const StringValueConverter().fromJson(json['reportId']),
  actionType: (json['actionType'] as num).toInt(),
  actor: json['actor'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  detailsHash: json['detailsHash'] as String,
  oldStatus: (json['oldStatus'] as num).toInt(),
  newStatus: (json['newStatus'] as num).toInt(),
);

Map<String, dynamic> _$BlockchainAuditEntryDtoToJson(
  _BlockchainAuditEntryDto instance,
) => <String, dynamic>{
  'reportId': const StringValueConverter().toJson(instance.reportId),
  'actionType': instance.actionType,
  'actor': instance.actor,
  'timestamp': instance.timestamp,
  'detailsHash': instance.detailsHash,
  'oldStatus': instance.oldStatus,
  'newStatus': instance.newStatus,
};

_BlockchainVerificationResultDto _$BlockchainVerificationResultDtoFromJson(
  Map<String, dynamic> json,
) => _BlockchainVerificationResultDto(
  reportId: json['report_id'] as String,
  protectedSnapshotToken: json['protected_snapshot_token'] as String?,
  verifiedAt: json['verified_at'] as String?,
  reason: json['verify_status_reason'] as String?,
  verificationPending:
      _readVerificationPending(json, 'verification_pending') as bool? ?? false,
  verificationState: json['verify_status'] as String?,
  onChainId: const NullableStringConverter().fromJson(json['on_chain_id']),
  verified: json['verified'] as bool,
  originalSnapshotVerified: json['original_snapshot_verified'] as bool?,
  currentContentVerified: json['current_content_verified'] as bool?,
  statusVerified: json['status_verified'] as bool?,
  blockchainData: json['blockchain_data'] as Map<String, dynamic>,
  auditHistory: (json['audit_history'] as List<dynamic>)
      .map((e) => BlockchainAuditEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String,
  notFoundOnChain: json['not_found_on_chain'] as bool? ?? false,
  connectionError: json['connection_error'] as bool? ?? false,
  isAnchored: json['is_anchored'] as bool? ?? true,
);

Map<String, dynamic> _$BlockchainVerificationResultDtoToJson(
  _BlockchainVerificationResultDto instance,
) => <String, dynamic>{
  'report_id': instance.reportId,
  'protected_snapshot_token': instance.protectedSnapshotToken,
  'verified_at': instance.verifiedAt,
  'verify_status_reason': instance.reason,
  'verification_pending': instance.verificationPending,
  'verify_status': instance.verificationState,
  'on_chain_id': const NullableStringConverter().toJson(instance.onChainId),
  'verified': instance.verified,
  'original_snapshot_verified': instance.originalSnapshotVerified,
  'current_content_verified': instance.currentContentVerified,
  'status_verified': instance.statusVerified,
  'blockchain_data': instance.blockchainData,
  'audit_history': instance.auditHistory,
  'message': instance.message,
  'not_found_on_chain': instance.notFoundOnChain,
  'connection_error': instance.connectionError,
  'is_anchored': instance.isAnchored,
};
