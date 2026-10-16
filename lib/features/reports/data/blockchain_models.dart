import 'package:freezed_annotation/freezed_annotation.dart';
import 'report_models.dart'
    show NullableIntConverter, NullableStringConverter, StringValueConverter;

part 'blockchain_models.freezed.dart';
part 'blockchain_models.g.dart';

Object? _readVerificationPending(Map<dynamic, dynamic> json, String key) =>
    json[key] == true || json['scan_incomplete'] == true;

@freezed
abstract class BlockchainAuditEntryDto with _$BlockchainAuditEntryDto {
  const factory BlockchainAuditEntryDto({
    @JsonKey(name: 'reportId') @StringValueConverter() required String reportId,
    @JsonKey(name: 'actionType')
    @NullableIntConverter()
    required int actionType,
    @JsonKey(name: 'actor') required String actor,
    @JsonKey(name: 'timestamp') @NullableIntConverter() required int timestamp,
    @JsonKey(name: 'detailsHash') required String detailsHash,
    @JsonKey(name: 'oldStatus') @NullableIntConverter() required int oldStatus,
    @JsonKey(name: 'newStatus') @NullableIntConverter() required int newStatus,
  }) = _BlockchainAuditEntryDto;

  factory BlockchainAuditEntryDto.fromJson(Map<String, dynamic> json) =>
      _$BlockchainAuditEntryDtoFromJson(json);
}

@freezed
abstract class BlockchainVerificationResultDto
    with _$BlockchainVerificationResultDto {
  const factory BlockchainVerificationResultDto({
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'protected_snapshot_token') String? protectedSnapshotToken,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'verify_status_reason') String? reason,
    @JsonKey(name: 'verification_pending', readValue: _readVerificationPending)
    @Default(false)
    bool verificationPending,
    @JsonKey(name: 'verify_status') String? verificationState,
    @JsonKey(name: 'on_chain_id') @NullableStringConverter() String? onChainId,
    required bool verified,
    @JsonKey(name: 'original_snapshot_verified') bool? originalSnapshotVerified,
    @JsonKey(name: 'current_content_verified') bool? currentContentVerified,
    @JsonKey(name: 'status_verified') bool? statusVerified,
    @JsonKey(name: 'blockchain_data')
    required Map<String, dynamic> blockchainData,
    @JsonKey(name: 'audit_history')
    required List<BlockchainAuditEntryDto> auditHistory,
    required String message,
    @JsonKey(name: 'not_found_on_chain') @Default(false) bool notFoundOnChain,
    @JsonKey(name: 'connection_error') @Default(false) bool connectionError,
    @JsonKey(name: 'is_anchored') @Default(true) bool isAnchored,
  }) = _BlockchainVerificationResultDto;

  factory BlockchainVerificationResultDto.fromJson(Map<String, dynamic> json) =>
      _$BlockchainVerificationResultDtoFromJson(json);
}
