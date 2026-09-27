# Gates: Help & Safety

OWNS: lib/features/auth/presentation/profile_screen.dart, lib/features/help/**, test/features/help/**, test/features/auth/profile_help_safety_test.dart, pubspec.yaml, pubspec.lock, build/help-safety-screenshots/**

Scope: Add offline Help & Safety navigation, searchable FAQs, verified emergency call actions, and focused Flutter coverage.

- [x] G0: acceptance ledger contains runnable outcome checks
      CHECK: node ../.agents/skills/unlazy/scripts/gate-lint.mjs GATES-help-safety.md
      EXPECT: LINT OK
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=ba9998364d89c712acb5b17873689a388e1fd1231d4e74d8c7a8cc579b0b5534; output-bytes=280

- [x] G1: Profile navigation, FAQ search/accordion, hotline validation/call intent, and local offline content pass focused tests
      CHECK: "C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat" test test/features/help test/features/auth/profile_help_safety_test.dart
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=2ac25718390f0adeb4b871e9c1a7d8b66d9507de6aa37ba146de39bba9445ac0; output-bytes=7839

- [x] G2: changed Dart files have no analyzer diagnostics
      CHECK: "C:\Users\domin\Coding\Flutter-SDK\flutter\bin\dart.bat" analyze lib/features/help test/features/help lib/features/auth/presentation/profile_screen.dart test/features/auth/profile_help_safety_test.dart
      EXPECT: No issues found!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=0095f236841a6dd517e25d1cebebe4f5df81b20071519b91a223055763d787b7; output-bytes=93

- [x] G3: changed Dart files already match formatter output
      CHECK: "C:\Users\domin\Coding\Flutter-SDK\flutter\bin\dart.bat" format --set-exit-if-changed lib/features/auth/presentation/profile_screen.dart lib/features/help test/features/help test/features/auth/profile_help_safety_test.dart
      EXPECT: /Formatted \d+ files \(0 changed\)/
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=51706e21f0651f3ca168b090cdcf911713025f96198e0d0c0b3525a73ef5c4b1; output-bytes=47

- [x] G4: Android debug APK builds
      CHECK: "C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat" build apk --debug && if exist "build\app\outputs\flutter-apk\app-debug.apk" (echo ANDROID_APK_BUILD_OK) else (exit /b 1)
      EXPECT: ANDROID_APK_BUILD_OK
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=a23a235a2ea6c915af523627c672279e4dd144ba49ccf069ebb446c5885f991f; output-bytes=5983

- [x] G5: patch has no whitespace errors
      CHECK: git diff --check && echo DIFF_CHECK_OK
      EXPECT: DIFF_CHECK_OK
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=220374976439/72 entries; EXPECT=matched; output-sha256=f16da71def2d3005f0c181b13bea1d20db209eddafa399ea2375be880b106dbc; output-bytes=797

- [x] G6: emergency hotline numbers and support-entry decisions are source-verified
      EVIDENCE: The Philippine eHotlines portal lists 911 as the National Emergency Hotline: https://ehotlines.e.gov.ph/. Urdaneta CDRRMO page has placeholder/conflicting details, so local numbers need direct city confirmation: https://www.urdaneta-city.gov.ph/copy-of-gso. No existing support channel was found, so no Contact Support row was added.

- [x] G7: screenshots show the delivered Profile section, FAQ, and hotline screens
      EVIDENCE: Captured and reviewed on the Pixel 9a API 36 AVD: build/help-safety-screenshots/profile-latest.png, build/help-safety-screenshots/help-faq-final.png, build/help-safety-screenshots/hotlines-final.png. Android intent test opened Google Dialer with tel:911; no call was placed.
