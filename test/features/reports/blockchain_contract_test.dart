import 'package:bayantrack_mobile/features/reports/data/blockchain_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';

Map<String, dynamic> verification({Object? onChainId}) => {
  'report_id': 'RPT-1',
  'on_chain_id': onChainId,
  'verified': true,
  'status_verified': null,
  'blockchain_data': <String, dynamic>{},
  'audit_history': [
    {
      'reportId':
          '0xcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd',
      'actionType': 0,
      'actor': '0xwriter',
      'timestamp': 1,
      'detailsHash': '0xcommitment',
      'oldStatus': 0,
      'newStatus': 0,
    },
  ],
  'message': 'ok',
};

void main() {
  test('maps original proof and changed current content independently', () {
    final payload = verification(onChainId: '0xcheckpoint')
      ..['verified'] = false
      ..['original_snapshot_verified'] = true
      ..['current_content_verified'] = false;
    final dto = BlockchainVerificationResultDto.fromJson(payload);
    final result = ReportMapper.blockchainVerificationFromDto(dto);
    expect(result.verified, isFalse);
    expect(result.originalSnapshotVerified, isTrue);
    expect(result.currentContentVerified, isFalse);
  });

  test('legacy responses do not invent original or current hash proof', () {
    final result = ReportMapper.blockchainVerificationFromDto(
      BlockchainVerificationResultDto.fromJson(verification()),
    );
    expect(result.originalSnapshotVerified, isNull);
    expect(result.currentContentVerified, isNull);
  });

  test('exposes on_chain_id and report identifiers as strings', () {
    final current = BlockchainVerificationResultDto.fromJson(
      verification(
        onChainId:
            '0xabababababababababababababababababababababababababababababababab',
      ),
    );
    expect(current.onChainId, startsWith('0x'));
    expect(current.auditHistory.single.reportId, startsWith('0x'));

    final legacy = BlockchainVerificationResultDto.fromJson(
      verification(onChainId: 7),
    );
    expect(legacy.onChainId, '7');
  });
}
