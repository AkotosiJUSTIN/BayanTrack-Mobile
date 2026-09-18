# Gates: KYC ID capture framing guide

OWNS: lib/features/kyc/presentation/id_capture_screen.dart, lib/features/kyc/presentation/kyc_form_screen.dart, test/features/kyc/id_capture_screen_test.dart, test/features/kyc/kyc_form_screen_test.dart, lib/l10n/app_en.arb, lib/l10n/app_fil.arb, lib/l10n/app_localizations.dart, lib/l10n/app_localizations_en.dart, lib/l10n/app_localizations_fil.dart, pubspec.yaml, pubspec.lock, ios/Runner/Info.plist, GATES-kyc-capture-outline.md

Scope: add a responsive, accessible ID framing guide to camera capture while preserving existing front/back, OCR, upload, validation, and KYC behavior.

- [x] G0: this acceptance ledger is valid
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-kyc-capture-outline.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=32f5c3f1468a09dac2e3c46f037279892f65e4735708028148c23bb1318855b0; output-bytes=170

- [x] G1: ID capture guide and front/back screen variants render at common viewport sizes
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat test test/features/kyc/id_capture_screen_test.dart && echo ID capture guide tests passed
  EXPECT: ID capture guide tests passed
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=a274bd33251303f3038fd863d8b4c0e8a4b81b6484240782689aaa1344a807e9; output-bytes=397

- [x] G2: existing KYC form flow keeps ID front/back slots and OCR review behavior
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat test test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_ocr_review_test.dart test/features/kyc/kyc_ocr_parser_test.dart && echo KYC flow tests passed
  EXPECT: KYC flow tests passed
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=ddca0f67c1a01bb21987b2a7a5ea5c0aab67748d7a9bb046979dadcf994cb598; output-bytes=5452

- [x] G3: changed Dart files are formatted and targeted analysis passes
  CHECK: C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\cache\\dart-sdk\\bin\\dart.exe format --output=none --set-exit-if-changed lib/features/kyc/presentation/id_capture_screen.dart lib/features/kyc/presentation/kyc_form_screen.dart test/features/kyc/id_capture_screen_test.dart test/features/kyc/kyc_form_screen_test.dart lib/l10n/app_localizations.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_fil.dart && C:\\Users\\domin\\Coding\\Flutter-SDK\\flutter\\bin\\flutter.bat analyze lib/features/kyc/presentation/id_capture_screen.dart lib/features/kyc/presentation/kyc_form_screen.dart test/features/kyc/id_capture_screen_test.dart test/features/kyc/kyc_form_screen_test.dart && echo KYC ID capture quality gates passed
  EXPECT: KYC ID capture quality gates passed
  CWD: .
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=498cbb87558c/71 entries; EXPECT=matched; output-sha256=395b1b3a2b526e51ca865ed7e56427709a5c91407a4f4fc825a764df0ca1e8e7; output-bytes=180

- [x] G4: camera capture remains advisory and accessible, with safe-area/light-dark compatibility and no authenticity claim added
  EVIDENCE: source review: CameraPreview stays visible under IdCaptureGuide; guide is IgnorePointer-only and capture requires camera readiness, not overlay detection; SafeArea, ColorScheme, 48px back control, 64px shutter, light/dark and compact-landscape tests cover accessibility/responsiveness; OCR authenticity notice remains unchanged.
