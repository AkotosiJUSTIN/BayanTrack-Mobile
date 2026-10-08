import 'package:bayantrack_mobile/features/help/data/help_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundles all FAQ groups and LGU hotline data locally', () {
    expect(helpFaqCategories.map((category) => category.title), [
      'Getting Started',
      'Reporting an Issue',
      'Report Status & Tracking',
      'My Reports',
      'Identity Verification',
      'Account & Security',
      'Privacy',
      'Notifications',
      'Troubleshooting',
    ]);
    expect(
      helpFaqCategories.every((category) => category.entries.isNotEmpty),
      isTrue,
    );
    expect(emergencyHotlines.map((hotline) => (hotline.name, hotline.number)), [
      ('National Emergency Hotline', '911'),
      ('Ambulance / Rescue', '+63 917 818 5374'),
      ('Ambulance / Rescue', '+63 917 159 1545'),
      ('Bureau of Fire Protection', '+63 917 184 4611'),
      ('Philippine National Police', '+63 998 589 5135'),
      ('Philippine National Police', '+63 916 226 3641'),
    ]);
    expect(neighboringEmergencyHotlines, isEmpty);
  });

  test('FAQ search matches categories, questions, and answers', () {
    expect(
      filterHelpFaqCategories('identity').map((category) => category.title),
      ['Identity Verification', 'Privacy'],
    );
    expect(
      filterHelpFaqCategories('refresh token').single.entries.single.question,
      'What happens when my session expires?',
    );
    expect(filterHelpFaqCategories('   '), helpFaqCategories);
  });

  test('only canonical phone numbers produce a tel call intent', () {
    expect(hotlineCallUri('911'), Uri(scheme: 'tel', path: '911'));
    expect(
      hotlineCallUri('+639171234567'),
      Uri(scheme: 'tel', path: '+639171234567'),
    );
    for (final hotline in emergencyHotlines) {
      expect(
        hotlineCallUri(hotline.number).toString(),
        'tel:${hotline.number.replaceAll(' ', '')}',
      );
    }
    expect(
      hotlineCallUri(emergencyHotlines[1].number)!.path,
      isNot(emergencyHotlines[1].number),
    );
    expect(hotlineCallUri(null), isNull);
    expect(hotlineCallUri('  '), isNull);
    expect(hotlineCallUri('911 ext 2'), isNull);
    expect(hotlineCallUri('tel:911'), isNull);
  });
}
