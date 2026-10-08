# Gates: light notification surface hierarchy

OWNS: lib/core/theme/app_colors.dart, test/core/theme/app_theme_contrast_test.dart, test/features/citizen_tabs_screen_test.dart

Scope: separate the light citizen page background from white read cards and the blue unread notification surface without changing dark mode or notification behavior.

- [x] G0: this task ledger has valid runnable gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-notification-hierarchy.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=48630b7361dd44ee870917b12c3d19b9d7bdea738aaca16bb04d4cab83b772d2; output-bytes=8

- [x] G1: light hierarchy and dark-mode regression tests pass
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat test test/features/citizen_tabs_screen_test.dart && C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat test test/core/theme/app_theme_contrast_test.dart && echo notification hierarchy tests passed
  EXPECT: notification hierarchy tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=e690b23f8e8dee28a81e6579d02bd8a101f7b78f0ad2f06215dadde7923a978b; output-bytes=1300

- [x] G2: affected Dart files are formatted and analyze cleanly
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\dart.bat format --output=none --set-exit-if-changed lib/core/theme/app_colors.dart test/core/theme/app_theme_contrast_test.dart test/features/citizen_tabs_screen_test.dart && C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat analyze lib/core/theme/app_colors.dart test/core/theme/app_theme_contrast_test.dart test/features/citizen_tabs_screen_test.dart && echo notification hierarchy quality gates passed
  EXPECT: notification hierarchy quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=fd316fdee0f2f020dfa3aad3d9b647531acc445c67536f2c7555806bfd400648; output-bytes=188

- [x] G3: final scoped diff has no whitespace errors
  CHECK: git diff --check -- lib/core/theme/app_colors.dart test/core/theme/app_theme_contrast_test.dart test/features/citizen_tabs_screen_test.dart && echo notification hierarchy diff passed
  EXPECT: notification hierarchy diff passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=93b8eb11c7edeae016801f1fe871676b2cc7be7478dcedddb04425d23ea706ac; output-bytes=310
