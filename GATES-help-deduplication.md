# Gates: Help and emergency navigation deduplication

OWNS: lib/features/help/presentation/help_screens.dart, test/features/help/help_screens_test.dart, test/features/auth/profile_help_safety_test.dart, GATES-help-deduplication.md

Scope: Keep one emergency entry on Profile and show searchable offline FAQs without a duplicate hotline list.

- [x] G1: Profile has one emergency entry, FAQs start with visible search, and emergency calls still work
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test test/features/help test/features/auth/profile_help_safety_test.dart
      EXPECT: All tests passed!
      EVIDENCE: Executed directly through PowerShell in BayanTrack-Mobile; exit=0; EXPECT matched; 17 tests passed. New visible-search regression failed against original implementation before fix; profile duplicate-entry assertion also failed before fix. Tests cover retained emergency navigation, every configured call URI, offline FAQ expansion/search, invalid numbers, missing dialer and large text.

- [x] G2: Mobile static analysis passes
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat analyze
      EXPECT: No issues found!
      EVIDENCE: Executed directly through PowerShell in BayanTrack-Mobile with --no-pub; exit=0; EXPECT matched; No issues found! (ran in 62.5s).

- [x] G3: Changed Dart files match formatter output
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\dart.bat format --output=none --set-exit-if-changed lib/features/help/presentation/help_screens.dart test/features/help/help_screens_test.dart test/features/auth/profile_help_safety_test.dart
      EXPECT: (0 changed)
      EVIDENCE: Executed directly through PowerShell in BayanTrack-Mobile; exit=0; EXPECT matched; Formatted 3 files (0 changed). git diff --check also passed. Oxlint fix/final checks and oxfmt ran but found no applicable files; Dart tools provide coverage.

Review: Only Mobile UI and widget tests change; no API, payload, role, permission, notification or realtime contract changes. Shared emergency section used by Quick Report stays unchanged. No device/emulator visual check or Android rebuild performed for this widget-only removal.

Maintenance limitation: Ran workspace `graphify update .`; stopped its owned processes after several minutes without output. Existing graph.json is 128,622,270 bytes and retained its original modification time at last inspection. Graph refresh remains incomplete.
