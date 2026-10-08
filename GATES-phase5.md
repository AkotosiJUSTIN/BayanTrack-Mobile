# Gates: offline-first phase 5 hardening

OWNS: lib/core/network/**, lib/features/auth/**, lib/features/images/**, lib/features/reports/**, test/core/network/**, test/features/auth/**, test/features/images/**, test/features/reports/**, lib/l10n/**

Scope: Harden authentication and offline synchronization, close proven retry/handoff UX gaps, and verify the mobile acceptance path without changing workflow rules.

- [x] G0: gate oracles are structurally valid
      CHECK: node ../.agents/skills/unlazy/scripts/gate-lint.mjs GATES-phase5.md
      EXPECT: LINT OK
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=decbb54bf1641d9c4b7d7e77c6b4331177acf612b869e0a8a9701ad1e24dcb24; output-bytes=395

- [x] G1: token refresh resolves all waiters and cannot overwrite a changed account session
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test test/core/network/auth_interceptor_test.dart test/features/auth/auth_session_expiry_test.dart test/features/auth/auth_session_repository_impl_test.dart
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=eba276ae2ac3e7ad3dd328ed2edf9a49e1348bff7bf358820d7cb3a7ab8bfcd6; output-bytes=8207

- [x] G2: outbox retry, owner isolation, evidence queue and reachability behavior pass focused tests
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test test/features/reports/report_create_outbox_test.dart test/features/reports/report_offline_cache_test.dart test/features/images/evidence_upload_queue_test.dart test/core/providers/backend_reachability_provider_test.dart
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=d9f57e2e126e140106ccf6a9daf4988efd4d9eb9f42369a7b09209d8e46cbf35; output-bytes=11724

- [x] G3: pending evidence handoff and Emergency messaging remain truthful and actionable
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test test/features/reports/my_reports_screen_offline_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/quick_report_screen_test.dart
      EXPECT: All tests passed!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=e47289b74ddd8283ac4c55e38e026e1bf8da226875df9df8879f1cf333233bea; output-bytes=13408

- [x] G4: changed Dart files pass targeted analysis
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat analyze --no-pub lib/core/network/auth_interceptor.dart lib/features/auth/domain/auth_session_repository.dart lib/features/auth/data/repositories/auth_session_repository_impl.dart lib/features/auth/presentation/auth_wrapper.dart lib/features/images/data/evidence_upload_queue.dart lib/features/images/data/evidence_upload_queue_provider.dart lib/features/reports/data/report_cache_store.dart lib/features/reports/data/report_create_outbox.dart lib/features/reports/presentation/my_reports_screen.dart lib/features/reports/reports_di.dart lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_fil.dart test/core/network/auth_interceptor_test.dart test/features/auth/auth_session_repository_impl_test.dart test/features/reports/report_create_outbox_test.dart test/features/reports/my_reports_screen_offline_test.dart test/features/reports/report_offline_cache_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/quick_report_screen_test.dart test/features/images/evidence_upload_queue_test.dart
      EXPECT: No issues found!
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=ac5a77a893baad00f0108c669fe2b5d090930683740b4c18e6040b7f2a474505; output-bytes=96

- [x] G5: updated and new Dart files are formatted
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib/core/network/auth_interceptor.dart lib/features/auth/domain/auth_session_repository.dart lib/features/auth/data/repositories/auth_session_repository_impl.dart lib/features/auth/presentation/auth_wrapper.dart lib/features/images/data/evidence_upload_queue.dart lib/features/images/data/evidence_upload_queue_provider.dart lib/features/reports/data/report_cache_store.dart lib/features/reports/data/report_create_outbox.dart lib/features/reports/presentation/my_reports_screen.dart lib/features/reports/reports_di.dart lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_fil.dart test/core/network/auth_interceptor_test.dart test/features/auth/auth_session_repository_impl_test.dart test/features/reports/report_create_outbox_test.dart test/features/reports/my_reports_screen_offline_test.dart test/features/reports/report_offline_cache_test.dart test/features/reports/emergency_report_screen_test.dart test/features/reports/quick_report_screen_test.dart test/features/images/evidence_upload_queue_test.dart
      EXPECT: (0 changed)
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=d67144b038f4c0efa0f0dc65cb6fffc058a9d87070b3c9ba7a0c187cb5212e01; output-bytes=48

- [x] G6: full analyzer findings are no worse than the recorded baseline
      EVIDENCE: `flutter analyze --no-pub` exit 1 with 38 existing lints: 24 warnings and 14 infos; baseline was 40 (24 warnings and 16 infos). No warning increase; two auth-wrapper infos were removed. Analyzing all 52 changed Dart files found 12 infos and no warnings/errors; Phase 5 targeted analysis passed with no issues.

- [x] G7: Android debug APK builds successfully
      CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat build apk --debug --no-pub
      EXPECT: Built build\app\outputs\flutter-apk\app-debug.apk
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=d0ec2111b7cd6c5e6dbc6e7e59588a411d8fbe72d8f976c41c997c356d1dbb8a; output-bytes=127

- [x] G8: final patch has no whitespace errors
      CHECK: git diff --check && echo DIFF_CHECK_PASSED
      EXPECT: DIFF_CHECK_PASSED
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=747d707285b63ceb9504545815d3888389fce97bb57fae4fe7cf83be21a414a0; output-bytes=5244

- [x] G9: current graph reflects final code
      CHECK: graphify update ..
      EXPECT: graph
      EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=63280f151fa7/72 entries; EXPECT=matched; output-sha256=b49a74f3fd204bd8a9a085be865af0faad3f58e20214999f5dd53469f0e74d9e; output-bytes=1669

- [x] G10: device acceptance exercises API loss, process death, reconnect and duplicate prevention
      EVIDENCE: Backend stayed running on host port 8000. Emulator API access was blocked/restored with `adb reverse --remove tcp:8000` / `adb reverse tcp:8000 tcp:8000`. Quick no-photo report queued offline, survived force-stop, and synced once after reconnect (server count 17→18). Full report with staged photo survived force-stop and synced once with one `/reports/` creation and one `/images/upload/` handoff (18→19); restart kept count 19. Emergency displayed `NOT YET TRANSMITTED` and existing local-emergency-services/cellular-call guidance, then synced after reconnect (19→20); pending card cleared and another restart kept count 20. Live A/B logout-switch, proxy-dropped response, and network-flapping scenarios were not exercised on device; owner isolation, idempotent lost-response replay, status failures, and retry behavior passed focused unit tests. The later emergency copy change is covered by focused widget tests. Cold-start offline auth remains a known blocker; cached identity was not accepted as authorization.

- [x] G11: final Ponytail review finds no unnecessary complexity in scoped changes
      EVIDENCE: reviewed Phase 5 diffs after final test/build pass; no dead code, duplicated storage system, speculative abstraction, or avoidable dependency found. Existing secure storage, auth path, outbox, and evidence queue remain reused.
