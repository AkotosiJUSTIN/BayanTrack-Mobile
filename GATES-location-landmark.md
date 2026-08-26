# Gates: Citizen report location and landmark enrichment

OWNS: lib/features/reports/**, lib/features/auth/**, lib/core/constants/api_constants.dart, lib/l10n/**, test/features/reports/**, test/features/auth/**

Scope: restore coordinate-driven barangay selection and add optional nearby landmark suggestions without blocking report submission.

- [x] G0: gate ledger is structurally valid
  CHECK: node ../.agents/skills/unlazy/scripts/gate-lint.mjs GATES-location-landmark.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=1c9b0890e8e808fb8479818980f341f1acee9f139926c0f65c78486338350c4b; output-bytes=286

- [x] G1: mobile location resolution, landmark classification, manual-preservation, and report payload tests pass
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat test --no-pub test/features/reports/location_landmark_test.dart test/features/reports/report_municipality_contract_test.dart test/features/reports/reports_repository_impl_test.dart test/features/reports/quick_report_screen_test.dart && echo MOBILE_LOCATION_TESTS_OK
  EXPECT: MOBILE_LOCATION_TESTS_OK
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=d66963a7287881b1829d41530e1cc75f91b4c0d0229a8d85b4ce21d39d5005ed; output-bytes=5562

- [x] G2: backend location lookup and report-location contract tests pass
  CHECK: venv\Scripts\python.exe -m pytest tests/authentication/test_nearby_landmarks.py tests/reports/test_municipality_submission.py tests/reports/test_report_storage.py tests/reports/test_submission_service.py -q && echo BACKEND_LOCATION_TESTS_OK
  EXPECT: BACKEND_LOCATION_TESTS_OK
  CWD: ../BayanTrack-Backend/backend
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Backend\backend; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=12008d5c612bcb6830e61a56f1976840c5340c4c50a065a8a1aae76addbdfac7; output-bytes=2998

- [x] G3: mobile format and analyzer gates pass
  CHECK: C:\Users\domin\Coding\Flutter-SDK\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib/core/constants/api_constants.dart lib/features/auth/data/auth_models.dart lib/features/auth/domain/auth_repository.dart lib/features/auth/data/repositories/auth_repository_impl.dart lib/features/reports/presentation/new_report/new_report_controller.dart lib/features/reports/presentation/new_report/quick_report_geo.dart lib/features/reports/presentation/new_report/quick_report_screen.dart lib/features/reports/presentation/new_report/new_report_location_screen.dart lib/features/reports/presentation/new_report/new_report_details_screen.dart test/features/reports/location_landmark_test.dart test/features/reports/report_municipality_contract_test.dart test/features/reports/reports_repository_impl_test.dart && C:\Users\domin\Coding\Flutter-SDK\flutter\bin\flutter.bat analyze --no-pub --no-fatal-infos --no-fatal-warnings && echo MOBILE_QUALITY_OK
  EXPECT: MOBILE_QUALITY_OK
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=ade984a8d9a0b01015e1feb5e131fcd45339345ec939f43555971943dc4b9750; output-bytes=23789

- [x] G4: backend compile and Django checks pass
  CHECK: venv\Scripts\python.exe -m compileall -q . && venv\Scripts\python.exe manage.py check && echo BACKEND_QUALITY_OK
  EXPECT: BACKEND_QUALITY_OK
  CWD: ../BayanTrack-Backend/backend
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Backend\backend; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=86de2f3bcc07ce12cd5710f6703533be8b3d7926ad0d4a9d9bf0b90f86a1fdda; output-bytes=177

- [x] G5: changed repository files have no whitespace errors
  CHECK: git -C BayanTrack-Mobile diff --check && git -C BayanTrack-Backend diff --check && echo DIFF_CHECK_OK
  EXPECT: DIFF_CHECK_OK
  CWD: ..
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack; path=41c170f74cca/65 entries; EXPECT=matched; output-sha256=a3c3d9de3b87f54de108668eb1732c12111028e6bc160d7bcb9437bfbc7d810e; output-bytes=2383

- [x] G6: synthetic coordinates exercise coordinate-to-barangay and nearby-landmark outcomes, including provider failure fallback
  EVIDENCE: Mobile location_landmark_test.dart covers nearest/distant coordinate pairs, pin replacement, strong/no/multiple landmark outcomes, manual preservation, and failed lookup fallback; backend landmark/report tests use synthetic coordinates with mocked provider responses.

- [x] G7: provider integration sends no client secret or bearer credential to the public nearby-place provider
  EVIDENCE: test_nearby_landmarks.py captures the backend urllib request and asserts no Authorization header and no api_key URL material; the mobile contract exposes only the first-party /auth/nearby-landmarks/ endpoint and no provider credential.
