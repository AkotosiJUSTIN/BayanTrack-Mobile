import 'package:bayantrack_mobile/features/reports/data/incident_catalog.g.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/widgets/incident_choice_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'canonical request and response preserve choice separately from category',
    () {
      const request = dto.CreateReportRequest(
        incidentTypeKey: 'reported_killing',
        incidentCatalogVersion: 'incident_catalog_v1',
      );
      expect(request.toJson()['incident_type_key'], 'reported_killing');
      expect(request.toJson()['category'], isNull);
      final report = ReportMapper.fromDto(
        dto.Report.fromJson({
          'id': 'synthetic',
          'category': 'Flood & Disaster Response',
          'incident_type': 'murder',
          'incident_type_key': 'reported_killing',
          'incident_type_display': 'Reported killing',
          'incident_catalog_version': 'incident_catalog_v1',
        }),
      );
      expect(report.incidentType, 'murder');
      expect(report.incidentTypeKey, 'reported_killing');
      expect(report.incidentTypeDisplay, 'Reported killing');
      expect(
        incidentDisplay(report.incidentTypeKey, 'fil', report.incidentType!),
        'Iniulat na pagpatay',
      );
      expect(
        incidentDisplay(null, 'fil', 'Old unknown text'),
        'Old unknown text',
      );
    },
  );

  test(
    'full-report draft restoration and clearing preserve advisory semantics',
    () {
      final container = ProviderContainer();
      final subscription = container.listen(
        newReportControllerProvider,
        (_, _) {},
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });
      final controller = container.read(newReportControllerProvider.notifier);
      controller.setIncident('fire', 'incident_catalog_v1');
      final snapshot = controller.submissionSnapshot();
      expect(snapshot['incidentTypeKey'], 'fire');
      expect(snapshot['category'], isNull);
      controller.restoreDraft(
        ReportDraft(
          schemaVersion: ReportDraft.currentSchemaVersion,
          draftId: 'test',
          ownerId: 'test',
          type: ReportDraftType.full,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          resumeStep: 'details',
          payload: snapshot,
          attachmentRefs: const [],
        ),
        attachments: const [],
      );
      expect(
        container.read(newReportControllerProvider).incidentTypeKey,
        'fire',
      );
      controller.setIncident(null, null);
      expect(controller.submissionSnapshot()['incidentTypeKey'], isNull);
    },
  );

  testWidgets(
    'offline selector offers choices and allows an unavailable selection to clear',
    (tester) async {
      String? selected = 'retired_choice';
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            incidentChoicesProvider.overrideWith(
              (ref) async => throw Exception('offline'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => IncidentChoiceField(
                  value: selected,
                  onChanged: (key, version) => setState(() {
                    selected = key;
                  }),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Previous choice — clear to remove'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Not specified'),
        -300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Not specified').last);
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(tester.takeException(), isNull);
      expect(
        bundledIncidentCatalog['incident_catalog_version'],
        'incident_catalog_v1',
      );
    },
  );
}
