class HelpFaqEntry {
  const HelpFaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}

class HelpFaqCategory {
  const HelpFaqCategory({required this.title, required this.entries});

  final String title;
  final List<HelpFaqEntry> entries;
}

class EmergencyHotline {
  const EmergencyHotline({
    required this.name,
    required this.number,
    this.municipalityId = 'urdaneta',
  });

  final String name;
  final String number;
  final String? municipalityId;
}

const helpFaqCategories = <HelpFaqCategory>[
  HelpFaqCategory(
    title: 'Getting Started',
    entries: [
      HelpFaqEntry(
        question: 'What is BayanTrack?',
        answer:
            'BayanTrack helps residents report local issues to the LGU and follow their progress.',
      ),
      HelpFaqEntry(
        question: 'How do I navigate the app?',
        answer:
            'Use Home, My Reports, Notifications, and Profile in the bottom bar. Tap the center plus button to start a Quick or Full Report.',
      ),
      HelpFaqEntry(
        question: 'Do I need to verify my email after signing up?',
        answer:
            'The current mobile sign-up flow creates your account and signs you in; it does not ask for an email verification code.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Reporting an Issue',
    entries: [
      HelpFaqEntry(
        question: 'What is Quick Report?',
        answer:
            'Quick Report sends a short issue description with its location. Before submitting, the app checks for reports within 500 meters and lets you review up to three nearby results.',
      ),
      HelpFaqEntry(
        question: 'What is a Full Report?',
        answer:
            'Full Report guides you through incident details, location, optional photos, and a final review before submission.',
      ),
      HelpFaqEntry(
        question: 'When should I use Emergency Report?',
        answer:
            'Use it to submit an urgent incident with its type and location. Confirm the incident and location before sending. BayanTrack does not dispatch emergency services; use the verified hotline shown on the Emergency Hotlines page for immediate danger.',
      ),
      HelpFaqEntry(
        question: 'How is report location set?',
        answer:
            'The app can use your device location, and the map flow lets you choose or adjust the incident point. Reports must be within the selected municipality service area.',
      ),
      HelpFaqEntry(
        question: 'Can I attach photos?',
        answer:
            'Yes. Add evidence from the camera or photo library in the report flow. Evidence uploads can remain queued for retry if the connection is unavailable.',
      ),
      HelpFaqEntry(
        question: 'What happens when nearby reports are found?',
        answer:
            'Quick Report shows up to three nearby reports so you can review them. You can return to your report or choose Submit Anyway; the app does not automatically merge it with another report.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Report Status & Tracking',
    entries: [
      HelpFaqEntry(
        question: 'What does Submitted or Under Review mean?',
        answer:
            'Your report was sent to the service for review. Some assigned or escalated workflow states are also shown as Under Review in the mobile status label.',
      ),
      HelpFaqEntry(
        question: 'How can I see assignment or acknowledgement?',
        answer:
            'Open the report in My Reports to see its current status and any department information returned by the service. The mobile app has no separate citizen acknowledgement step.',
      ),
      HelpFaqEntry(
        question: 'What does In Progress mean?',
        answer:
            'The report has moved into active work. My Reports shows the latest status returned by the service.',
      ),
      HelpFaqEntry(
        question: 'What does Resolved mean?',
        answer:
            'The service has marked the issue resolved. Open the report to review the resolution summary or evidence and confirm whether the issue was addressed.',
      ),
      HelpFaqEntry(
        question: 'How do I confirm a resolution?',
        answer:
            'For a resolved report, submit the citizen review. Confirmation requires your registered name and a drawn signature; rating and note are optional.',
      ),
      HelpFaqEntry(
        question: 'What if the issue is not resolved?',
        answer:
            'Choose the dispute or reopen option on the resolution review and provide a reason. The service handles the resulting reopen or escalation.',
      ),
      HelpFaqEntry(
        question: 'What does Closed mean?',
        answer:
            'Closed is a final status shown in My Reports. In the mobile citizen flow, confirming a satisfactory resolution closes the report; other closure actions are controlled by the service.',
      ),
      HelpFaqEntry(
        question: 'Where are archived reports?',
        answer:
            'My Reports has status filters, including Closed and Rejected. The current mobile app has no separate Archived folder.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'My Reports',
    entries: [
      HelpFaqEntry(
        question: 'How do I track a report?',
        answer:
            'Open My Reports, choose a status filter if needed, and tap a report to see its details and updates.',
      ),
      HelpFaqEntry(
        question: 'Where do report notifications appear?',
        answer:
            'Open Notifications for in-app updates. Profile settings also let you control email, push, status-change, comment, and assignment notifications.',
      ),
      HelpFaqEntry(
        question: 'Can I see the department response or resolution evidence?',
        answer:
            'When provided by the service, report details show the department response. The resolution review can show resolution notes and proof images.',
      ),
      HelpFaqEntry(
        question: 'What do Pending or Failed evidence uploads mean?',
        answer:
            'The report is submitted separately from its evidence upload. Pending or failed evidence stays in the upload queue; use its retry action when a connection is available.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Identity Verification',
    entries: [
      HelpFaqEntry(
        question: 'Why is identity verification needed?',
        answer:
            'Some protected actions require a verified account. Report submission is generally available before verification, while suspended accounts are blocked from report submission and protected writes.',
      ),
      HelpFaqEntry(
        question: 'Which IDs can I submit?',
        answer:
            'Current citizen submissions support National ID, Driver’s License, Passport, and UMID. The form only shows options accepted by the service.',
      ),
      HelpFaqEntry(
        question: 'What does ID scanning do?',
        answer:
            'OCR can fill form fields from an ID image. Review and correct extracted details before submitting; OCR can make mistakes.',
      ),
      HelpFaqEntry(
        question: 'How do verification review and resubmission work?',
        answer:
            'Profile shows Unverified, Pending, Verified, Rejected, Resubmit Requested, or Suspended. You can withdraw a pending submission or correct and resubmit when requested or rejected.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Account & Security',
    entries: [
      HelpFaqEntry(
        question: 'How do I change my password?',
        answer:
            'Open Profile and choose Change Password. You can also choose Forgot Password from Login if you cannot sign in.',
      ),
      HelpFaqEntry(
        question: 'How does OTP and MFA work in the mobile app?',
        answer:
            'The citizen mobile flow uses an email OTP for password recovery. Profile does not currently provide MFA setup or management.',
      ),
      HelpFaqEntry(
        question: 'What happens when my session expires?',
        answer:
            'The app attempts to refresh an expired access token using the saved refresh token. If refresh fails, the request fails; retry when online and sign in again if the session is rejected.',
      ),
      HelpFaqEntry(
        question: 'How do I recover my account?',
        answer:
            'From Login, choose Forgot Password, enter your email, verify the six-digit code, then set a new password. The code can be resent from that flow.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Privacy',
    entries: [
      HelpFaqEntry(
        question: 'Who can see my report?',
        answer:
            'Reports in public or citizen-visible workflow states can appear in the shared citizen feed. The public view hides reporter identity and internal fields, but includes report details such as location and evidence.',
      ),
      HelpFaqEntry(
        question: 'What personal information do other citizens see?',
        answer:
            'The public report view removes reporter identifiers and verification details. Keep personal details out of the report description and photos because report content can be visible in the shared feed.',
      ),
      HelpFaqEntry(
        question: 'Does a report have a private/public setting?',
        answer:
            'The mobile report form has no visibility switch. The service controls which reports enter the public feed.',
      ),
      HelpFaqEntry(
        question: 'Are my location and photos shared?',
        answer:
            'The report sends its incident location and selected evidence to the service. Public report details can include location and evidence, so only attach information appropriate to share.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Notifications',
    entries: [
      HelpFaqEntry(
        question: 'Which notifications can I control?',
        answer:
            'Profile settings provide email, push, status-change, comment, and assignment preferences. SMS preferences are not implemented in the mobile app.',
      ),
    ],
  ),
  HelpFaqCategory(
    title: 'Troubleshooting',
    entries: [
      HelpFaqEntry(
        question: 'What works offline?',
        answer:
            'These FAQs and the bundled emergency hotline list are available offline. Report submission and most account or report updates need a network connection; evidence uploads can queue for later retry.',
      ),
      HelpFaqEntry(
        question: 'What should I do if a report fails to submit?',
        answer:
            'Check your connection and retry from the report screen. Review My Reports before submitting again in case the service accepted the first attempt.',
      ),
      HelpFaqEntry(
        question: 'What if an evidence upload fails?',
        answer:
            'Open the evidence upload notice and retry when online. Pending uploads are stored locally so the app can resume them after a restart or reconnect.',
      ),
      HelpFaqEntry(
        question: 'What if the app cannot get my location?',
        answer:
            'Check device location services and app permission. In the standard report flow, choose or adjust the point on the map; reports outside the selected service area cannot be submitted.',
      ),
      HelpFaqEntry(
        question: 'What if I do not receive a password reset code?',
        answer:
            'Check that the email is correct and look in Spam or Junk. Use Resend Code in the password recovery flow, then enter the latest six-digit code.',
      ),
      HelpFaqEntry(
        question: 'Why can I not sign in?',
        answer:
            'Check your email, password, and connection. Use Forgot Password to reset your password; if the service still rejects sign-in, retry when online.',
      ),
    ],
  ),
];

// LGU-provided reference, added 2026-09-30. Reverify local contacts against
// the current official source before production release.
const emergencyHotlines = <EmergencyHotline>[
  EmergencyHotline(
    name: 'National Emergency Hotline',
    number: '911',
    municipalityId: null,
  ),
  EmergencyHotline(name: 'Ambulance / Rescue', number: '+63 917 818 5374'),
  EmergencyHotline(name: 'Ambulance / Rescue', number: '+63 917 159 1545'),
  EmergencyHotline(
    name: 'Bureau of Fire Protection',
    number: '+63 917 184 4611',
  ),
  EmergencyHotline(
    name: 'Philippine National Police',
    number: '+63 998 589 5135',
  ),
  EmergencyHotline(
    name: 'Philippine National Police',
    number: '+63 916 226 3641',
  ),
];

// Add only independently verified neighboring-LGU contacts, with their scope.
const neighboringEmergencyHotlines = <EmergencyHotline>[];

const emergencyServicesGuidance =
    'For immediate danger or life-threatening emergencies, contact emergency '
    'services directly. BayanTrack does not replace emergency response services.';

List<HelpFaqCategory> filterHelpFaqCategories(String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return helpFaqCategories;

  final matches = <HelpFaqCategory>[];
  for (final category in helpFaqCategories) {
    final matchingEntries = category.entries
        .where(
          (entry) =>
              category.title.toLowerCase().contains(normalizedQuery) ||
              entry.question.toLowerCase().contains(normalizedQuery) ||
              entry.answer.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
    if (matchingEntries.isNotEmpty) {
      matches.add(
        HelpFaqCategory(title: category.title, entries: matchingEntries),
      );
    }
  }
  return matches;
}

Uri? hotlineCallUri(String? number) {
  final formattedNumber = number?.trim();
  if (formattedNumber == null ||
      !RegExp(r'^\+?[0-9][0-9 ]*$').hasMatch(formattedNumber)) {
    return null;
  }
  final canonicalNumber = formattedNumber.replaceAll(' ', '');
  if (!RegExp(r'^\+?[0-9]{2,20}$').hasMatch(canonicalNumber)) {
    return null;
  }
  return Uri(scheme: 'tel', path: canonicalNumber);
}
