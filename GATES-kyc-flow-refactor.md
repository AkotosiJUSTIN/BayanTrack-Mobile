# Gates: OCR-first KYC flow

OWNS: lib/features/kyc/**, test/features/kyc/**, lib/l10n/**, GATES-kyc-flow-refactor.md

Scope: choose scan/manual verification, review OCR before applying autofill, preserve edits, and keep KYC resubmission compatible.

- [x] G0: this acceptance ledger contains valid runnable gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-kyc-flow-refactor.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=48630b7361dd44ee870917b12c3d19b9d7bdea738aaca16bb04d4cab83b772d2; output-bytes=8

- [x] G1: scan-first and manual-first paths, review application, safe OCR fallback, image replacement, and resubmission behavior pass focused tests
  CHECK: flutter test test/features/kyc/kyc_form_screen_test.dart test/features/kyc/kyc_ocr_review_test.dart test/features/kyc/kyc_ocr_parser_test.dart && echo kyc flow tests passed
  EXPECT: kyc flow tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=d3bf78f5c25520d3a4cb52ffe6fac44dd9b253da915f4347ef2b5e171e930f15; output-bytes=3581

- [x] G2: existing KYC behavior and localization tests remain passing
  CHECK: flutter test test/features/kyc test/core/utils/kyc_validators_test.dart test/l10n/localization_test.dart && echo existing KYC tests passed
  EXPECT: existing KYC tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=9ed15b46cbcd7c513e3fae99e08d2ea05794c2850d98c08ef0c0464b0748bb03; output-bytes=6061

- [x] G3: changed KYC code is formatted and relevant Flutter analysis passes
  CHECK: dart format --output=none --set-exit-if-changed lib/features/kyc test/features/kyc lib/l10n && flutter analyze lib/features/kyc test/features/kyc && echo kyc flow quality gates passed
  EXPECT: kyc flow quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=ae5fba9a14c9/72 entries; EXPECT=matched; output-sha256=5da68aa045b0c9fe08629248136c327e891d9360aa8bda4f70aee8e56ebdab58; output-bytes=175
