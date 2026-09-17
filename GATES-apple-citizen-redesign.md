# Gates: Apple-inspired citizen screen redesign

OWNS: lib/core/theme/**, lib/core/presentation/widgets/**, lib/features/navigation/main_navigation_shell.dart, lib/features/home/**, lib/features/reports/presentation/my_reports_screen.dart, lib/features/reports/presentation/widgets/priority_badge.dart, lib/features/notifications/presentation/**, lib/features/auth/presentation/profile_screen.dart, lib/features/auth/presentation/edit_profile_screen.dart, lib/features/auth/presentation/change_password_screen.dart, lib/features/auth/presentation/verification_widgets.dart, lib/features/kyc/presentation/kyc_status_screen.dart, test/core/theme/**, test/features/citizen_tabs_screen_test.dart, test/features/navigation/**, test/features/auth/profile_locale_test.dart, test/features/auth/edit_profile_screen_test.dart, test/features/kyc/kyc_status_screen_test.dart, test/features/notifications/**

Scope: shared tonal design system and polished citizen-facing Flutter screens with preserved behavior

- [x] G0: gate ledger syntax is valid
  CHECK: node ../.agents/skills/unlazy/scripts/gate-lint.mjs GATES-apple-citizen-redesign.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=c12deb7c99b1/71 entries; EXPECT=matched; output-sha256=5881f5af4e4c3f5b53dbe1b513d6df34832036af47480f8f167333a60114abf0; output-bytes=291

- [x] G1: focused citizen-screen, theme, navigation, profile, verification, and notification tests pass
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test test/core/theme/app_theme_contrast_test.dart test/features/citizen_tabs_screen_test.dart test/features/navigation/main_navigation_shell_test.dart test/features/auth/profile_locale_test.dart test/features/auth/edit_profile_screen_test.dart test/features/kyc/kyc_status_screen_test.dart test/features/notifications/notification_preferences_controller_test.dart
  EXPECT: All tests passed!
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=c12deb7c99b1/71 entries; EXPECT=matched; output-sha256=20bace3ac92c03b9958418db4d8bdd1c458ac38c6118cbcb7a22deba60e6a2b0; output-bytes=4345

- [x] G2: changed mobile Dart files are formatted and relevant analysis passes
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib/core/theme lib/core/presentation/widgets lib/features/navigation/main_navigation_shell.dart lib/features/home/presentation lib/features/reports/presentation/my_reports_screen.dart lib/features/reports/presentation/widgets/priority_badge.dart lib/features/notifications/presentation lib/features/auth/presentation/profile_screen.dart lib/features/auth/presentation/edit_profile_screen.dart lib/features/auth/presentation/change_password_screen.dart lib/features/auth/presentation/verification_widgets.dart lib/features/kyc/presentation/kyc_status_screen.dart test/core/theme test/features/citizen_tabs_screen_test.dart test/features/navigation test/features/auth/profile_locale_test.dart test/features/auth/edit_profile_screen_test.dart test/features/kyc/kyc_status_screen_test.dart test/features/notifications && C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat analyze lib/core/theme lib/core/presentation/widgets lib/features/navigation/main_navigation_shell.dart lib/features/home/presentation lib/features/reports/presentation/my_reports_screen.dart lib/features/reports/presentation/widgets/priority_badge.dart lib/features/notifications/presentation lib/features/auth/presentation/profile_screen.dart lib/features/auth/presentation/edit_profile_screen.dart lib/features/auth/presentation/change_password_screen.dart lib/features/auth/presentation/verification_widgets.dart lib/features/kyc/presentation/kyc_status_screen.dart test/core/theme test/features/citizen_tabs_screen_test.dart test/features/navigation test/features/auth/profile_locale_test.dart test/features/auth/edit_profile_screen_test.dart test/features/kyc/kyc_status_screen_test.dart test/features/notifications
  EXPECT: No issues found!
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=c12deb7c99b1/71 entries; EXPECT=matched; output-sha256=19a844eb55b53354cc2adbd529e15aa8eb8f283a2d2072e237e443c7677a7978; output-bytes=144

- [ ] G3: full Mobile regression suite passes
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test --concurrency=1
  EXPECT: All tests passed!
  CWD: .
  EVIDENCE: pending

- [x] G4: Android debug build succeeds
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat build apk --debug --target-platform android-x64
  EXPECT: Built build\app\outputs\flutter-apk\app-debug.apk
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=c12deb7c99b1/71 entries; EXPECT=matched; output-sha256=5e1942fbdebc3afb2469cd1c0bc495c9becac61677d364a836524ba936ef524c; output-bytes=127

- [x] G5: light and dark citizen screens were manually reviewed on the Android emulator
  EVIDENCE: 2026-09-18: installed x64 debug APK on emulator-5554; reviewed light Home/list and Verification, plus dark Profile, Notifications, Notification Settings, Edit Profile, and Change Password; no clipping or harsh default borders observed.

- [x] G6: final diff preserves existing business logic, routes, localization, APIs, permissions, and unrelated working-tree changes
  EVIDENCE: 2026-09-18: reviewed Mobile diff and repo statuses; changes confined to shared theme/presentation/widgets/tests plus this ledger, with pre-existing report-flow/localization edits preserved; unrelated Backend edits were observed and left untouched, Web stayed clean; no endpoint, enum, permission, or state-layer changes.

ABANDON: G3 pre-existing evidence-draft cleanup, KYC form duplicate-error, and report-detail semantics failures remain outside this visual redesign scope; handoff required for release gate repair
