# Gates: Phase 4 evidence handoff

OWNS: lib/features/reports/data/report_create_outbox.dart, lib/features/reports/reports_di.dart, test/features/reports/report_create_outbox_test.dart

Scope: make acknowledged report evidence handoff restart-safe through the existing upload queue.

- [x] G0: this ledger has valid runnable outcomes
      CHECK: node ..\.agents\skills\unlazy\scripts\gate-lint.mjs GATES-phase4.md
      EXPECT: LINT OK
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=ba3f8893671655889f552bead7d4349cc5b33eaa8b5bbe14a7a31474fe1d37f6; output-bytes=275

- [x] G1: report-create handoff recovery tests pass
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat test test/features/reports/report_create_outbox_test.dart --reporter compact
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=6d0e970bb62567bb8b1fc25039779999bcc0d27eb6edff69cd41615f661d48d2; output-bytes=10635

- [x] G2: existing evidence queue regressions pass
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat test test/features/images/evidence_upload_queue_test.dart --reporter compact
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=4934004969434b3ea57050f33a70191d6d4f19e43f3aec9c7c39f58ff6395d59; output-bytes=11435

- [x] G3: changed Dart files are formatted
      CHECK: ..\..\Flutter-SDK\flutter\bin\dart.bat format --set-exit-if-changed lib/features/reports/data/report_create_outbox.dart lib/features/reports/reports_di.dart test/features/reports/report_create_outbox_test.dart
      EXPECT: Formatted
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=e2b84052659d83c2c420ce83f6d7641cbe36d94e0ec22f6a58374d89233f5440; output-bytes=47

- [x] G4: changed Mobile source and tests analyze cleanly
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat analyze lib/features/reports/data/report_create_outbox.dart lib/features/reports/reports_di.dart test/features/reports/report_create_outbox_test.dart
      EXPECT: No issues found!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=4345200523be1fe91bbb099cebb8b0b684aaee159987876fd944168a0040edce; output-bytes=5930

- [x] G5: full analyzer baseline findings are recorded separately
      EVIDENCE: flutter analyze exited 1 with 40 findings (24 warnings, 16 infos); none touch Phase 4 files. Phase 3 GATES.md already recorded full-analyzer gate unmet; Phase 4 changed-file analysis passes G4.

- [x] G6: Android debug APK builds
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat build apk --debug
      EXPECT: Built build\app\outputs\flutter-apk\app-debug.apk
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=7f279f5d7cff64235b9b2f71be7f671295e782b64501b7182aaeda6231ca2656; output-bytes=5961

- [x] G7: Git reports no whitespace errors
      CHECK: powershell -NoProfile -Command "git diff --check; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; Write-Output 'DIFF CHECK PASSED'"
      EXPECT: DIFF CHECK PASSED
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=ee6c2b00a793313c08ca8b67bddc50dbb7192a5b5e7246c201ed68a011ce194a; output-bytes=4976

- [x] G8: workspace knowledge graph reflects source changes
      EVIDENCE: graphify update . exited 0; AST extraction completed; graph reported no topology changes.
