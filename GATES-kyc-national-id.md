# Gates: National ID OCR propagation

OWNS: lib/features/kyc/**, test/features/kyc/**, lib/l10n/**, GATES-kyc-national-id.md

Scope: route National ID and PhilSys OCR through the correct parser, preserve raw extraction, and propagate reviewed identity/address/ID fields into the KYC draft.

- [x] G0: this acceptance ledger contains valid runnable gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-kyc-national-id.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=48630b7361dd44ee870917b12c3d19b9d7bdea738aaca16bb04d4cab83b772d2; output-bytes=8

- [x] G1: National ID parser routing, raw text, field extraction, corrections, downstream draft, manual fallback, and resubmission tests pass
  CHECK: flutter test test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_ocr_review_test.dart test/features/kyc/kyc_ocr_parser_test.dart && echo national ID OCR tests passed
  EXPECT: national ID OCR tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=72815d86d6fbbd66aa90266ff0f2fa518fc0b635f6c418df2e7e14068e2afc0c; output-bytes=4804

- [x] G2: existing KYC behavior and localization tests remain passing
  CHECK: flutter test test/features/kyc test/core/utils/kyc_validators_test.dart test/l10n/localization_test.dart && echo existing KYC tests passed
  EXPECT: existing KYC tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=3200742dd761eb06c02f3a3e64487e623a26d632b6abdd7fe604fbaa87d43231; output-bytes=7288

- [x] G3: changed KYC code is formatted and relevant Flutter analysis passes
  CHECK: dart format --output=none --set-exit-if-changed lib/features/kyc test/features/kyc lib/l10n && flutter analyze lib/features/kyc test/features/kyc && echo national ID OCR quality gates passed
  EXPECT: national ID OCR quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=dbaea532a70fb805472b827058fd4c910bdcaed07fb23aeafd56166bf9b4dbe0; output-bytes=182
