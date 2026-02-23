import 'package:freezed_annotation/freezed_annotation.dart';

part 'blockchain_models.freezed.dart';
part 'blockchain_models.g.dart';

@freezed
abstract class BlockchainAuditEntryDto with _$BlockchainAuditEntryDto {
  const factory BlockchainAuditEntryDto({
    @JsonKey(name: 'reportId') required int reportId,
    @JsonKey(name: 'actionType') required int actionType,
    @JsonKey(name: 'actor') required String actor,
    @JsonKey(name: 'timestamp') required int timestamp,
    @JsonKey(name: 'detailsHash') required String detailsHash,
    @JsonKey(name: 'oldStatus') required String oldStatus,
    @JsonKey(name: 'newStatus') required String newStatus,
  }) = _BlockchainAuditEntryDto;

  factory BlockchainAuditEntryDto.fromJson(Map<String, dynamic> json) =>
      _$BlockchainAuditEntryDtoFromJson(json);
}

@freezed
abstract class BlockchainVerificationResultDto
    with _$BlockchainVerificationResultDto {
  const factory BlockchainVerificationResultDto({
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'on_chain_id') int? onChainId,
    required bool verified,
    @JsonKey(name: 'status_verified') required bool statusVerified,
    @JsonKey(name: 'blockchain_data')
    required Map<String, dynamic> blockchainData,
    @JsonKey(name: 'audit_history')
    required List<BlockchainAuditEntryDto> auditHistory,
    required String message,
  }) = _BlockchainVerificationResultDto;

  factory BlockchainVerificationResultDto.fromJson(Map<String, dynamic> json) =>
      _$BlockchainVerificationResultDtoFromJson(json);
}
