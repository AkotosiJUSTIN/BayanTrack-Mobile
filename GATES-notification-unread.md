# Gates: light-mode unread notification surface

OWNS: lib/core/theme/app_colors.dart, lib/features/notifications/presentation/notifications_screen.dart, test/features/citizen_tabs_screen_test.dart

Scope: strengthen only the light-mode unread notification card surface while preserving read cards, dark mode, layout, interaction, and accessibility behavior.

- [x] G0: this task ledger has valid runnable gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-notification-unread.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=f0b8281e2317dbf8fba75e06725eabaef7e06ddd5326483fbfb8a799ad0bfcdc; output-bytes=170

- [x] G1: notification surface regression tests pass
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat test test/features/citizen_tabs_screen_test.dart test/core/theme/app_theme_contrast_test.dart && echo notification surface tests passed
  EXPECT: notification surface tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=492c006573f41d6c78c320e36bce515784f30548d8924f85d62d7df4630ae571; output-bytes=2333

- [x] G2: affected Dart files are formatted and analyze cleanly
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\dart.bat format --output=none --set-exit-if-changed lib/core/theme/app_colors.dart lib/features/notifications/presentation/notifications_screen.dart test/features/citizen_tabs_screen_test.dart test/core/theme/app_theme_contrast_test.dart && C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat analyze lib/core/theme/app_colors.dart lib/features/notifications/presentation/notifications_screen.dart test/features/citizen_tabs_screen_test.dart test/core/theme/app_theme_contrast_test.dart && echo notification quality gates passed
  EXPECT: notification quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=0c121a6f4d932403a4116a95c79f56bf1ddb456a53ec9b2cc0fd45bf25d6bea2; output-bytes=178

- [x] G3: light unread/read distinction, dark-mode preservation, readable blue hierarchy, and no layout or decorative-border regression are verified by focused widget tests
  EVIDENCE: citizen_tabs_screen_test.dart asserts the light unread token, quieter read surface, original dark blend, 16px radius, and BorderStyle.none; app_theme_contrast_test.dart asserts primary and secondary text contrast >= 4.5.
