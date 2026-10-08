# Gates: keyboard-ime-jank

OWNS: lib/features/home/presentation/home_screen.dart, lib/features/kyc/presentation/kyc_form_screen.dart, test/features/citizen_tabs_screen_test.dart, test/features/kyc/**

Scope: reduce Flutter UI work during Android keyboard animation while preserving KYC input behavior

- [x] G0: gate ledger is structurally valid
  CHECK: node C:/Users/domin/Coding/BayanTrack/.agents/skills/unlazy/scripts/gate-lint.mjs .unlazy/keyboard-ime-jank/GATES.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=7d9575fe50d1/71 entries; EXPECT=matched; output-sha256=7628d78d1401f2ce01d8d8837ffda5b90fdbceb5eacb83afbdc171f2bfea02db; output-bytes=176

- [x] G1: Home focus and focused KYC/OCR tests pass
  CHECK: powershell -NoProfile -Command "& 'C:/Users/domin/Coding/Flutter-SDK/flutter/bin/flutter.bat' test test/features/citizen_tabs_screen_test.dart test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_ocr_review_test.dart"
  EXPECT: All tests passed!
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=7d9575fe50d1/71 entries; EXPECT=matched; output-sha256=3dacd80adc3f6939de34f60bb259ab2032936499869aa1ef9fe761bcd492516e; output-bytes=6328

- [x] G2: changed Home and KYC files have no analyzer issues
  CHECK: powershell -NoProfile -Command "& 'C:/Users/domin/Coding/Flutter-SDK/flutter/bin/flutter.bat' analyze --no-pub lib/features/home/presentation/home_screen.dart test/features/citizen_tabs_screen_test.dart lib/features/kyc/presentation/kyc_form_screen.dart test/features/kyc/kyc_form_screen_test.dart"
  EXPECT: No issues found
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=7d9575fe50d1/71 entries; EXPECT=matched; output-sha256=3b35a07309bcc37fbd2fd98cc97a7e49b91be03682fe4c7a97495cfd4ebe93b0; output-bytes=96

- [x] G3: changed Home and KYC files remain formatted
  CHECK: powershell -NoProfile -Command "& 'C:/Users/domin/Coding/Flutter-SDK/flutter/bin/cache/dart-sdk/bin/dart.exe' format --output=none --set-exit-if-changed lib/features/home/presentation/home_screen.dart test/features/citizen_tabs_screen_test.dart lib/features/kyc/presentation/kyc_form_screen.dart; if ($LASTEXITCODE -eq 0) { Write-Output FORMAT_OK; exit 0 } else { exit $LASTEXITCODE }"
  EXPECT: FORMAT_OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=7d9575fe50d1/71 entries; EXPECT=matched; output-sha256=22479c01c3df4afcdda679dea4e5b0dbae91d568200beb1c805e8942a2a1f573; output-bytes=58

- [x] G4: profile APK builds from current source
  CHECK: powershell -NoProfile -Command "$env:JAVA_HOME='C:/Program Files/Eclipse Adoptium/jdk-21.0.10.7-hotspot'; & 'C:/Users/domin/Coding/Flutter-SDK/flutter/bin/flutter.bat' build apk --profile --no-pub"
  EXPECT: app-profile.apk
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=7d9575fe50d1/71 entries; EXPECT=matched; output-sha256=5062cf253e6990857f6579f85830d442ed31c70e05ca7c88ed147aa212f07674; output-bytes=139

- [ ] G5: identical real-device keyboard interaction shows improved UI/raster metrics
  EVIDENCE: profile APK installed on Xiaomi 24117RN76G. Baseline gfxinfo: 1,677 frames, 266 janky (15.86%), p90 77 ms, p99 150 ms, 259 missed vsyncs. ADB synthetic tap did not open IME; manual physical interaction remains required for valid after-metrics.
