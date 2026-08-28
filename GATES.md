# Gates: citizen mobile public-service redesign

OWNS: lib/features/auth/presentation/profile_screen.dart, lib/features/home/presentation/**, lib/features/navigation/main_navigation_shell.dart, lib/features/notifications/presentation/notifications_screen.dart, lib/features/reports/presentation/**, lib/features/reports/presentation/widgets/**, lib/features/kyc/presentation/**, lib/l10n/**, test/features/citizen_tabs_screen_test.dart, test/features/auth/profile_locale_test.dart, test/features/reports/**, test/features/kyc/**, test/l10n/**, GATES.md

Scope: align citizen home, my reports, notifications, profile, report creation, dispute review, identity verification, and report details with one accessible public-service mobile experience while preserving workflow, contracts, validation, permissions, and routing.

- [x] G0: the acceptance ledger has valid runnable and manual gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b6efa643938d/68 entries; EXPECT=matched; output-sha256=12306fbaf46b76499601f1e15abc58afb4209102e77836f34d2a8b3c3fb21957; output-bytes=268

- [ ] G1: focused citizen-screen, report, dispute, verification, and localization tests pass
  CHECK: flutter test test/features/citizen_tabs_screen_test.dart test/features/auth/profile_locale_test.dart test/features/reports/new_report_flow_screen_test.dart test/features/reports/quick_report_screen_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/citizen_review_screen_test.dart test/features/reports/report_detail_screen_test.dart test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_status_screen_test.dart test/l10n/localization_test.dart && echo focused mobile UI tests passed
  EXPECT: focused mobile UI tests passed
  EVIDENCE: exit=1; output='flutter' is not recognized as an internal or external command; blocked by missing Flutter SDK, so focused tests were not executed

- [ ] G2: Dart formatting and Flutter static analysis pass
  CHECK: dart format --output=none --set-exit-if-changed lib test && flutter analyze && echo mobile quality gates passed
  EXPECT: mobile quality gates passed
  EVIDENCE: exit=1; output='dart' is not recognized as an internal or external command; blocked by missing Dart/Flutter SDK, so formatting and analyze were not executed

- [ ] G3: the complete mobile test suite passes
  CHECK: flutter test && echo full mobile tests passed
  EXPECT: full mobile tests passed
  EVIDENCE: exit=1; output='flutter' is not recognized as an internal or external command; blocked by missing Flutter SDK, so the full suite was not executed

- [ ] G4: runtime checks cover narrow and large phones, keyboard open, light and dark themes, English and Filipino, focus order, and overflow for the four citizen tabs plus dispute, verification, and report details
  EVIDENCE: blocked: Flutter SDK and a runnable device/emulator toolchain are unavailable in this environment; source-level guards cover the compact responsive home selector, scrollable report lists, fixed keyboard-safe wizard actions, theme tokens, semantic navigation targets, and 48px+ primary controls, but no runtime result is claimed

- [x] G5: affected UI keeps existing workflow, permissions, API contracts, and bilingual localization behavior
  EVIDENCE: source review confirms existing controller calls, routes, arguments, validation branches, status/priority precedence, and dispute payload fields are unchanged; localization reference check passed, with `noVerificationSubmitted` added in matching English/Filipino ARB and generated delegate files
