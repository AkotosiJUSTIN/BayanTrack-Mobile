# BayanTrack Mobile

Flutter citizen application for reporting incidents, tracking status,
identity verification, notifications, and profile management.

## Current capabilities

- Municipality-aware Quick and standard report submission with location and
  optional evidence.
- Durable, owner-scoped post-submit evidence intents with restart recovery,
  bounded retry, manual retry, dismissal, and missing-file handling.
- Report list/detail/closure flows and authenticated realtime invalidation.
- Backend-owned five-level priority display with queue, suggestion, and legacy
  compatibility precedence.
- Identity-verification submission, status, and resubmission.
- Basic profile editing, avatar upload/removal, and refresh on realtime/app
  lifecycle events.
- Server-owned notification preferences that reload safely across account
  switching.
- Responsive onboarding, splash, login, OTP, password, and registration
  surfaces using optimized WebP runtime assets.

## Setup

Use a Flutter SDK that provides Dart 3.10.7 or newer (the version constraint
is in `pubspec.yaml`).

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

API addressing is supplied at run time with `--dart-define`:

- Android emulator: omit the defines and use the `10.0.2.2` default;
- LAN device: pass `BAYANTRACK_API_BASE_URL=http://<host-ip>:8000/api` and
  `BAYANTRACK_MEDIA_BASE_URL=http://<host-ip>:8000`;
- USB device: use the same defines with `127.0.0.1` after
  `adb reverse tcp:8000 tcp:8000`;
- production: pass the deployed API and media URLs.

See the
[`Network Deployment` guide](../BayanTrack-Backend/Readmes/Network_Deployment.md)
for the current workspace startup and LAN guide.

## Quality gates

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Documentation

- [`../SYSTEM_REFERENCE.md`](../SYSTEM_REFERENCE.md)
- [`../docs/ai-explanations.md`](../docs/ai-explanations.md)
- [`MOBILE_PRIORITIZATION_INTEGRATION.md`](MOBILE_PRIORITIZATION_INTEGRATION.md)
- [`SPEC_MOBILE.md`](SPEC_MOBILE.md)
- [`PERMISSIONS.md`](PERMISSIONS.md)
