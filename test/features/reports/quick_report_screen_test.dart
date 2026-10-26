import 'package:bayantrack_mobile/features/reports/data/emergency_catalog.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

// Mode-specific Quick/Fast screen cases are covered by the unified emergency suite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'offline catalog provides localized situations without obsolete not_sure',
    () async {
      final catalog = await EmergencyCatalog.bundled();
      expect(catalog.types, hasLength(9));
      expect(catalog.types.first.key, 'fire_smoke');
      expect(catalog.types.first.localized(true), 'Sunog o usok');
      expect(catalog.types.first.situations.first.key, 'building_fire');
      expect(
        catalog.types.first.situations.first.localized(true),
        'Sunog sa gusali',
      );
      expect(catalog.types.last.categoryKey, isNull);
      expect(catalog.types.last.situations.map((s) => s.key), [
        'rescue_needed',
        'assistance_needed',
        'other_unknown',
      ]);
      for (final type in catalog.types) {
        expect(type.situations.map((s) => s.key), isNot(contains('not_sure')));
        final other = type.situations.singleWhere(
          (s) => s.key == 'other_unknown',
        );
        expect(other.localized(false), 'Other');
        expect(other.localized(true), 'Iba');
      }
    },
  );

  test(
    'context omits blank notes and canonical summary uses English labels',
    () async {
      final catalog = await EmergencyCatalog.bundled();
      final type = catalog.types.first;
      final situation = type.situations.first;
      expect(
        emergencyContext(
          type: type,
          situation: situation,
          danger: 'unknown',
          notes: '  ',
        ),
        {
          'version': 1,
          'type_key': 'fire_smoke',
          'situation_key': 'building_fire',
          'immediate_danger': 'unknown',
        },
      );
      expect(
        emergencySummary(type, situation, 'no', '  Keep clear  '),
        'Fire or smoke: Building fire.\nInjury or immediate danger: No.\nNotes: Keep clear',
      );
    },
  );

  test(
    'DTOs preserve context/catalog and omit absent optional legacy fields',
    () {
      const context = {
        'version': 1,
        'type_key': 'fire_smoke',
        'situation_key': 'building_fire',
        'immediate_danger': 'yes',
      };
      final report = dto.Report.fromJson({
        'id': 'e1',
        'is_emergency': true,
        'emergency_context': context,
      });
      expect(report.emergencyContext, context);
      expect(report.toJson()['emergency_context'], context);
      expect(ReportMapper.fromDto(report).emergencyContext, context);
      expect(ReportMapper.fromDto(report).isQuickReport, isTrue);
      expect(
        const dto.Report(
          id: 'legacy',
        ).toJson().containsKey('emergency_context'),
        isFalse,
      );
      expect(
        const dto.CreateReportRequest().toJson().containsKey(
          'emergency_context',
        ),
        isFalse,
      );
      final options = dto.ReportFormOptions.fromJson({
        'categories': [],
        'statuses': [],
        'severity_levels': [],
        'emergency_catalog': {'version': 1, 'types': []},
      });
      expect(options.emergencyCatalog!['version'], 1);
      expect(options.toJson()['emergency_catalog'], {
        'version': 1,
        'types': [],
      });
    },
  );

  test(
    'enrichment preserves sanitized server prefix and caps appended budget',
    () {
      const original = 'Original notes: A &amp; B';
      expect(
        appendEmergencyDetails(original, ' More help '),
        '$original\n\nAdditional details:\nMore help',
      );
      expect(
        emergencyDetailsRemaining(original),
        500 - original.length - emergencyDetailsPrefix.length,
      );
      expect(emergencyDetailsRemaining('x' * 500), 0);
      expect(
        appendEmergencyDetails(
          original,
          'x' * emergencyDetailsRemaining(original),
        ).length,
        500,
      );
    },
  );
}
