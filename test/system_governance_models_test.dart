import 'package:flutter_test/flutter_test.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';

void main() {
  test(
    'published translations are authoritative and require version metadata',
    () {
      final terms = PublishedTerms.fromJson({
        'version_id': 'version-2',
        'checksum': 'checksum-2',
        'translations': {
          'en': {
            'title': 'Terms',
            'terms': 'Updated English terms',
            'privacy': 'Privacy',
          },
          'fil': {
            'title': 'Mga tuntunin',
            'terms': 'Bagong tuntunin',
            'privacy': 'Pribasiya',
          },
        },
      });
      expect(terms.translation('fil').terms, 'Bagong tuntunin');
      expect(terms.consent('fil'), {
        'terms_version_id': 'version-2',
        'terms_checksum': 'checksum-2',
        'terms_language': 'fil',
      });
    },
  );

  test('malformed published documents cannot be accepted', () {
    expect(
      () => PublishedTerms.fromJson({'version_id': ''}),
      throwsFormatException,
    );
  });

  test(
    'pending consent and maintenance pause ordinary work, not emergency work',
    () {
      final state = SystemGovernanceState.fromJson({
        'maintenance': {
          'enabled': true,
          'message': 'Maintenance',
          'revision': 1,
        },
        'latest_terms_version': 'version-2',
        'accepted_terms_version': 'version-1',
        'terms_acceptance_required': true,
      });
      expect(state.permitsMutation(isEmergency: false), isFalse);
      expect(state.permitsMutation(isEmergency: true), isTrue);
      expect(state.maintenanceMessage, 'Maintenance');
    },
  );
}
