# Gates: BayanTrack Mobile error repair

OWNS: lib/**, test/**, GATES.md

Scope: identify and repair current Mobile analyzer, test, formatting, and debug-build failures without changing shared contracts.

- [x] G0: gate ledger is structurally valid
  CHECK: node ../.agents/skills/unlazy/scripts/gate-lint.mjs GATES.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=da48d039ca53/66 entries; EXPECT=matched; output-sha256=48630b7361dd44ee870917b12c3d19b9d7bdea738aaca16bb04d4cab83b772d2; output-bytes=8

- [x] G1: Dart formatting passes without changes
  CHECK: dart format --output=none --set-exit-if-changed lib/core/presentation/widgets/app_toast.dart lib/features/reports/presentation/citizen_review_screen.dart test/features/auth/edit_profile_screen_test.dart test/features/auth/forgot_password_screen_test.dart test/features/auth/profile_locale_test.dart test/features/onboarding/onboarding_screen_test.dart test/features/reports/citizen_review_screen_test.dart test/features/reports/quick_report_screen_test.dart test/features/splash/splash_screen_test.dart && echo FORMAT_OK
  EXPECT: FORMAT_OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=da48d039ca53/66 entries; EXPECT=matched; output-sha256=60104be4c96bc674d3edffadc62e4b25decbb0b23eaa7948d3b3c576a2361aaa; output-bytes=58

- [x] G2: Flutter analyzer reports no errors
  CHECK: flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings && echo ANALYZE_OK
  EXPECT: ANALYZE_OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=da48d039ca53/66 entries; EXPECT=matched; output-sha256=85b53d8b8a6bd5ba38502d2d4a023e40fef87572296ce9d7a67a01e21a93a88a; output-bytes=23580

- [x] G3: Flutter test suite passes
  CHECK: flutter test --no-pub && echo TEST_OK
  EXPECT: TEST_OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=da48d039ca53/66 entries; EXPECT=matched; output-sha256=5749c21e030581372daae6203abe594c71caf317e6f9531d6925e7e9a801b603; output-bytes=39347

- [x] G4: Android debug build passes when local SDK supports it
  CHECK: flutter build apk --debug --no-pub && echo BUILD_OK
  EXPECT: BUILD_OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=da48d039ca53/66 entries; EXPECT=matched; output-sha256=9e4bbac27053bf0cb495630569fbe20ff211b97c1630b3661e4d451f379a86cb; output-bytes=137
