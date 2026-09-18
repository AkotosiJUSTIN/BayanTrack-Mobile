# Gates: OCR-assisted KYC autofill

OWNS: lib/features/kyc/**, test/features/kyc/**, lib/l10n/**, pubspec.yaml, pubspec.lock, GATES-kyc-ocr.md

Scope: run local OCR for four supported Philippine IDs, preserve existing entries, and review extracted fields before KYC submission.

- [x] G0: this acceptance ledger contains valid runnable or manual gates
  CHECK: node ..\\.agents\\skills\\unlazy\\scripts\\gate-lint.mjs GATES-kyc-ocr.md
  EXPECT: LINT OK
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=c12deb7c99b1/71 entries; EXPECT=matched; output-sha256=0bcdd1a39d23eca9e386c07d68aeccaea3ccfcb01bc3742650a687a8aaec10e6; output-bytes=158

- [x] G1: passport, LTO driver’s license, UMID, and PRC parser paths cover complete, partial, and unreadable OCR without guessing
  CHECK: flutter test test/features/kyc/kyc_ocr_parser_test.dart && echo kyc OCR parser tests passed
  EXPECT: kyc OCR parser tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b13eb4c6e96b/72 entries; EXPECT=matched; output-sha256=609a9cdf271de80f16bd1b1553acd42e983894aded9c7f0dfdec11d8723c8c70; output-bytes=1101

- [x] G2: editable OCR review preserves existing values and accepts an intentional user correction
  CHECK: flutter test test/features/kyc/kyc_ocr_review_test.dart test/features/kyc/kyc_form_screen_test.dart && echo kyc OCR review tests passed
  EXPECT: kyc OCR review tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b13eb4c6e96b/72 entries; EXPECT=matched; output-sha256=fbb82afb23c76695432f48cf05851f09e1e725cb08f09e123503b33764f4ee5b; output-bytes=501

- [x] G3: existing KYC validation, status, and localization tests remain passing
  CHECK: flutter test test/features/kyc test/core/utils/kyc_validators_test.dart test/l10n/localization_test.dart && echo existing KYC tests passed
  EXPECT: existing KYC tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b13eb4c6e96b/72 entries; EXPECT=matched; output-sha256=fa0fd34cf026dda8b8440abfe8ade92621698fc4a6eec7658cd8321d972e3b36; output-bytes=4691

- [x] G4: changed mobile code is formatted and relevant Flutter analysis passes
  CHECK: dart format --output=none --set-exit-if-changed lib/features/kyc test/features/kyc lib/l10n && flutter analyze lib/features/kyc test/features/kyc && echo kyc OCR quality gates passed
  EXPECT: kyc OCR quality gates passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b13eb4c6e96b/72 entries; EXPECT=matched; output-sha256=56245edbf4eca2bce24de78c6305fcd1eb258c29a7a8a8d9ef392623a36444a2; output-bytes=175

- [x] G5: light and dark review states expose manual-review limits and do not claim authenticity verification
  CHECK: flutter test test/features/kyc/kyc_ocr_theme_test.dart && echo kyc OCR theme tests passed
  EXPECT: kyc OCR theme tests passed
  EVIDENCE: exit=0; shell=C:\WINDOWS\system32\cmd.exe; cwd=C:\Users\domin\Coding\BayanTrack\BayanTrack-Mobile; path=b13eb4c6e96b/72 entries; EXPECT=matched; output-sha256=39579081b2b6989ea60c1d252d20bad647d59098f3047fdc4055c410532bfded; output-bytes=278
