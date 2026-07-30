# BayanTrack Mobile

Flutter citizen application for reporting incidents, tracking status,
identity verification, notifications, and profile management.

## Current capabilities

- Municipality-aware Quick and standard report submission with location and
  optional evidence.
- Durable, owner-scoped post-submit evidence intents with restart recovery,
  bounded retry, manual retry, dismissal, and missing-file handling.
- Report list/detail/closure flows and authenticated realtime invalidation.
- Identity-verification submission, status, and resubmission.
- Basic profile editing, avatar upload/removal, and refresh on realtime/app
  lifecycle events.
- Server-owned notification preferences that reload safely across account
  switching.
- Responsive onboarding, splash, login, OTP, password, and registration
  surfaces using optimized WebP runtime assets.

## Setup

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

API addressing is configured in
`lib/core/constants/api_constants.dart`:

- empty `_devServerIp`: Android emulator bridge `10.0.2.2`;
- LAN IP: real device on the same Wi-Fi/hotspot;
- `127.0.0.1`: physical Android device using
  `adb reverse tcp:8000 tcp:8000`.

See [`../Network_Deployment.md`](../Network_Deployment.md) for the current
workspace startup and LAN guide.

## Quality gates

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Documentation

- [`../PRD-Mobile.md`](../PRD-Mobile.md)
- [`SPEC_MOBILE.md`](SPEC_MOBILE.md)
- [`PERMISSIONS.md`](PERMISSIONS.md)
- [`../BayanTrack-System-Docs/02-architecture/mobile-architecture.md`](../BayanTrack-System-Docs/02-architecture/mobile-architecture.md)
