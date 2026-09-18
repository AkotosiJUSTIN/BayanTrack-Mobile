# Gates: KYC OCR side and draft consistency

OWNS: lib/features/kyc/**, test/features/kyc/**, lib/l10n/**, GATES-kyc-ocr-consistency.md

Scope: keep required ID sides, previews, OCR input, validation, reviewed identity values, manual entry, and resubmission consistent.

- [x] G0: this acceptance ledger contains valid runnable gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-kyc-ocr-consistency.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=48630b7361dd44ee870917b12c3d19b9d7bdea738aaca16bb04d4cab83b772d2; output-bytes=8

- [x] G1: side requirements, image replacement, OCR draft persistence, duplicate-step removal, manual entry, and resubmission pass focused KYC/OCR tests
  CHECK: flutter test test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_ocr_review_test.dart test/features/kyc/kyc_ocr_parser_test.dart && echo kyc consistency tests passed
  EXPECT: kyc consistency tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=6123f55cc6913e914c5380845929d7053073e53380461a6914eb240161b7d0a6; output-bytes=4168

- [x] G2: existing KYC behavior and localization tests remain passing
  CHECK: flutter test test/features/kyc test/core/utils/kyc_validators_test.dart test/l10n/localization_test.dart && echo existing KYC tests passed
  EXPECT: existing KYC tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=dc646c57b7351d784e03c06eac5de43dc17f740407b3b242758fe731d22589c4; output-bytes=6697

- [x] G3: changed KYC code is formatted and relevant Flutter analysis passes
  CHECK: dart format --output=none --set-exit-if-changed lib/features/kyc test/features/kyc lib/l10n && flutter analyze lib/features/kyc test/features/kyc && echo kyc consistency quality gates passed
  EXPECT: kyc consistency quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=8fea3b595ccd781e4c3d1b45b4602cf1189bfc2b53ee05da51ee2f8d736e3c42; output-bytes=182
