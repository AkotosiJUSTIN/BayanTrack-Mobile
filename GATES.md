# Gates: Phase 3 report-create outbox

OWNS: lib/features/reports/**, lib/features/images/data/evidence_upload_queue.dart, lib/features/images/data/evidence_upload_queue_provider.dart, lib/features/auth/presentation/auth_wrapper.dart, lib/core/domain/failures.dart, lib/core/network/error_mapper.dart, lib/l10n/**, test/features/reports/**, test/features/images/**

Scope: persist owner-scoped report creation until authenticated Backend acknowledgement, then map and hand off evidence safely.

- [x] G1: report outbox and screen behavior tests pass
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat test test/features/reports/report_create_outbox_test.dart test/features/images/evidence_upload_queue_test.dart --reporter compact
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=060e2be819702721961bb7c9fcb8e9abfdc2c0600b265cbed7021e7db1fbf839; output-bytes=15035

- [x] G2: report submit and pending-state screen tests pass
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat test test/features/reports/quick_report_screen_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/new_report_flow_screen_test.dart test/features/reports/new_report_image_draft_test.dart test/features/reports/report_draft_store_test.dart test/features/reports/my_reports_screen_offline_test.dart --reporter compact
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=725e0f1325b1328d202ab53de5cc441fd8da28b8fe2b56de2eb85e565874a918; output-bytes=25355

- [x] G3: outbox implementation and tests analyze cleanly
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat analyze lib/features/reports/data/report_create_outbox.dart test/features/reports/report_create_outbox_test.dart
      EXPECT: No issues found!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=2922d503530a124129fcbd2462cf1d967f3353c680fc2a18199d33926f09efe0; output-bytes=5930

- [ ] G4: full Mobile test suite passes
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat test
      EXPECT: All tests passed!
      EVIDENCE: pending

- [ ] G5: Flutter analyzer reports no issues
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat analyze
      EXPECT: No issues found!
      EVIDENCE: pending

- [x] G6: Android debug build succeeds
      CHECK: ..\..\Flutter-SDK\flutter\bin\flutter.bat build apk --debug
      EXPECT: Built build\app\outputs\flutter-apk\app-debug.apk
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=fd959d067513646a26242d9cd050efd162a7f00c0080e62c7b94a9fba837b509; output-bytes=5961

- [x] G7: tracked diff has no whitespace errors
      CHECK: powershell -NoProfile -Command "git diff --check; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; Write-Output 'DIFF CHECK PASSED'"
      EXPECT: DIFF CHECK PASSED
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=ee6c2b00a793313c08ca8b67bddc50dbb7192a5b5e7246c201ed68a011ce194a; output-bytes=4976
