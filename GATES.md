# Gates: citizen mobile public-service redesign

OWNS: lib/core/presentation/widgets/app_toast.dart, lib/core/presentation/widgets/civic_components.dart, lib/core/presentation/widgets/empty_content_placeholder.dart, lib/core/presentation/widgets/loading_overlay.dart, lib/core/providers/connectivity_provider.dart, lib/core/theme/app_colors.dart, lib/core/theme/app_theme.dart, lib/features/auth/presentation/auth_wrapper.dart, lib/features/auth/presentation/profile_screen.dart, lib/features/auth/presentation/verification_widgets.dart, lib/features/home/presentation/**, lib/features/images/presentation/evidence_upload_status_banner.dart, lib/features/navigation/main_navigation_shell.dart, lib/features/notifications/presentation/notifications_screen.dart, lib/features/reports/presentation/**, lib/features/reports/presentation/widgets/**, lib/features/kyc/presentation/**, lib/l10n/**, lib/main.dart, test/core/presentation/widgets/app_toast_test.dart, test/core/theme/app_theme_contrast_test.dart, test/features/citizen_tabs_screen_test.dart, test/features/auth/profile_locale_test.dart, test/features/reports/**, test/features/kyc/**, test/l10n/**, GATES.md

Scope: align citizen home, my reports, notifications, profile, report creation, dispute review, identity verification, and report details with one accessible public-service mobile experience, including centralized transient feedback and contrast-safe text/surfaces, while preserving workflow, contracts, validation, permissions, and routing.

- [x] G0: the acceptance ledger has valid runnable and manual gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES.md
  EXPECT: LINT OK
  EVIDENCE: gate-lint passed during the final verification pass; the ledger covers shared surface tokens and the top transient toast overlay.

- [ ] G1: focused citizen-screen, report, dispute, verification, and localization tests pass
  CHECK: flutter test test/core/theme/app_theme_contrast_test.dart test/core/presentation/widgets/app_toast_test.dart test/features/citizen_tabs_screen_test.dart test/features/auth/profile_locale_test.dart test/features/reports/new_report_flow_screen_test.dart test/features/reports/quick_report_screen_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/citizen_review_screen_test.dart test/features/reports/report_detail_screen_test.dart test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_status_screen_test.dart test/l10n/localization_test.dart && echo focused mobile UI tests passed
  EXPECT: focused mobile UI tests passed
  EVIDENCE: focused command executed 40 tests with 38 passing; contrast, citizen tabs, KYC, localization, report, and toast checks pass. Two unrelated Quick Report assertions remain: large-text right overflow and missing description ancestor in the map-controls test.

- [ ] G2: Dart formatting and Flutter static analysis pass
  CHECK: dart format --output=none --set-exit-if-changed lib test && flutter analyze && echo mobile quality gates passed
  EXPECT: mobile quality gates passed
  EVIDENCE: dart format was run; the targeted check still flags profile_screen.dart, while the repository-wide check reports 34 formatter-dirty files. Exact flutter analyze exits 1 with 106 repository warnings/info items.

- [ ] G3: the complete mobile test suite passes
  CHECK: flutter test && echo full mobile tests passed
  EXPECT: full mobile tests passed
  EVIDENCE: full suite completed with 8 failures: six evidence-draft filesystem cleanup tests and two unrelated Quick Report layout/accessibility tests; all other cases passed, including the new contrast regression test.

- [ ] G4: runtime checks cover narrow and large phones, keyboard open, light and dark themes, English and Filipino, focus order, and overflow for the four citizen tabs plus dispute, verification, report details, and transient feedback
  EVIDENCE: widget viewport tests cover compact and large-text Home layouts; top-toast tests cover replacement, safe top placement, timer, persistence, pause, and horizontal dismissal; debug APK builds successfully. Emulator launch was blocked by INSTALL_FAILED_INSUFFICIENT_STORAGE with about 547 MB free, so the manual theme/keyboard/focus/runtime matrix remains open.

- [x] G5: affected UI keeps existing workflow, permissions, API contracts, and bilingual localization behavior
  EVIDENCE: source review confirms existing controller calls, routes, arguments, validation branches, status/priority precedence, and dispute payload fields are unchanged; toast wiring only changes presentation feedback; localization reference check passed with matching English/Filipino ARB and generated delegate files
