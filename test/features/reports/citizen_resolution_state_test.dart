import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:flutter_test/flutter_test.dart';

dto.Report _response({bool? confirmed, String status = 'resolved'}) =>
    dto.Report.fromJson({
      'id': 'RPT-STATE-1',
      'description': 'Synthetic report',
      'status': status,
      'citizen_verified_at': '2026-10-12T08:00:00Z',
      'citizen_confirmed_resolved': ?confirmed,
    });

void main() {
  test('rejected response survives JSON roundtrip and mapping', () {
    final roundTrip = dto.Report.fromJson(_response(confirmed: false).toJson());
    final report = ReportMapper.fromDto(roundTrip);

    expect(roundTrip.citizenConfirmedResolved, isFalse);
    expect(report.citizenConfirmedResolved, isFalse);
    expect(report.citizenVerifiedAt, isNotNull);
    expect(report.hasCitizenConfirmedResolution, isFalse);
    expect(report.needsCitizenReview, isTrue);
  });

  test('confirmed response remains read only', () {
    final report = ReportMapper.fromDto(_response(confirmed: true));

    expect(report.hasCitizenConfirmedResolution, isTrue);
    expect(report.needsCitizenReview, isFalse);
  });

  test('legacy timestamp-only response remains read only', () {
    final report = ReportMapper.fromDto(_response());

    expect(report.citizenConfirmedResolved, isNull);
    expect(report.hasCitizenConfirmedResolution, isTrue);
    expect(report.needsCitizenReview, isFalse);
  });

  test('unreviewed resolution is counted as pending citizen review', () {
    final report = ReportMapper.fromDto(
      const dto.Report(id: 'RPT-STATE-1', status: 'resolved'),
    );

    expect(report.hasCitizenConfirmedResolution, isFalse);
    expect(report.needsCitizenReview, isTrue);
  });

  for (final status in ['escalated', 'in_progress', 'closed']) {
    test('$status report is not counted as pending citizen review', () {
      final report = ReportMapper.fromDto(
        _response(confirmed: false, status: status),
      );

      expect(report.needsCitizenReview, isFalse);
    });
  }

  test('confirmation flag participates in report equality', () {
    final disputed = ReportMapper.fromDto(_response(confirmed: false));
    final confirmed = ReportMapper.fromDto(_response(confirmed: true));

    expect(disputed, isNot(confirmed));
  });
}
