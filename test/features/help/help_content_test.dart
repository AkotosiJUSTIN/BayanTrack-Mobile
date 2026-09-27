import 'package:bayantrack_mobile/features/help/data/help_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundles all FAQ groups and verified hotline data locally', () {
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
    expect(emergencyHotlines.map((hotline) => hotline.number), ['911']);
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
    expect(hotlineCallUri(null), isNull);
    expect(hotlineCallUri('  '), isNull);
    expect(hotlineCallUri('911 ext 2'), isNull);
    expect(hotlineCallUri('tel:911'), isNull);
  });
}
