import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/presentation/widgets/priority_badge.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DTO and mapper preserve all five levels and qualitative factors', () {
    final names = ['very_low', 'low', 'medium', 'high', 'critical'];
    for (var rank = 1; rank <= 5; rank++) {
      final parsed = dto.Report.fromJson({
        'id': 'level-$rank',
        'priority_rank': rank,
        'priority_level': names[rank - 1],
        'suggested_priority_rank': rank,
        'suggested_priority_level': names[rank - 1],
        'queue_priority_rank': rank,
        'queue_priority_level': names[rank - 1],
        'priority_factors': {'hazard_severity': 'dangerous'},
      });
      final report = ReportMapper.fromDto(parsed);
      expect(report.priorityRank, rank);
      expect(report.suggestedPriorityRank, rank);
      expect(report.queuePriorityRank, rank);
      expect(report.displayPriorityLevel, PriorityLevel.values[rank - 1]);
      expect(report.priorityFactors['hazard_severity'], 'dangerous');
      final json = parsed.toJson();
      expect(json.containsKey('priority_score'), isFalse);
      expect(json.containsKey('suggested_priority_score'), isFalse);
      expect(json.containsKey('base_score'), isFalse);
    }
  });

  testWidgets('priority badge displays an integer out of five', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: PriorityBadge(
            priorityLevel: PriorityLevel.high,
            priorityRank: 4,
            showRank: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('4 / 5'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
