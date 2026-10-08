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
```

Run with target-specific API configuration below. Plain `flutter run` uses
the deployed HTTPS API; local development requires explicit overrides.

### Docker runner

The root Compose file includes an opt-in `mobile` profile. It builds the
Flutter/Android toolchain, mounts this repository, and stays idle until a
Flutter command is run; ordinary `docker compose up` never starts it.

From the workspace root:

```powershell
docker compose --profile mobile build mobile
docker compose --profile mobile up -d backend mobile
docker compose exec mobile flutter pub get
docker compose exec mobile dart run build_runner build --delete-conflicting-outputs
docker compose exec mobile flutter devices
```

The emulator or USB phone remains on the host. The container uses the host ADB
server, so start an Android emulator on the host for emulator mode, or enable
USB debugging and connect the phone for USB mode.

Emulator mode: in a host terminal, start an Android emulator first:

```powershell
emulator -list-avds
emulator -avd <avd-name>
```

Then pass the Android emulator host address:

```powershell
docker compose exec mobile flutter run -d <emulator-id> `
  --dart-define=BAYANTRACK_API_BASE_URL=http://10.0.2.2:8000/api `
  --dart-define=BAYANTRACK_MEDIA_BASE_URL=http://10.0.2.2:8000
```

USB mode uses the ADB reverse tunnel:

```powershell
docker compose exec mobile adb reverse tcp:8000 tcp:8000
docker compose exec mobile flutter run -d <phone-id> `
  --dart-define=BAYANTRACK_API_BASE_URL=http://127.0.0.1:8000/api `
  --dart-define=BAYANTRACK_MEDIA_BASE_URL=http://127.0.0.1:8000
```

Use `docker compose exec mobile flutter devices` to get the IDs. Stop the idle
runner with `docker compose stop mobile`.

API addressing is supplied at run time with `--dart-define`:

- Android emulator with a local backend: pass the `10.0.2.2` URLs above;
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

## Automatic Android releases

`.github/workflows/android-release.yml` builds on pushes to `main` and manual
runs. Publishing is restricted to `DvineConqueror/BayanTrack-Mobile`; incoming
pull requests cannot access signing secrets or publish releases.

Add these repository secrets under Settings > Secrets and variables > Actions:

- `ANDROID_KEYSTORE_BASE64`: Base64-encoded release keystore.
- `ANDROID_KEYSTORE_PASSWORD`: keystore password.
- `ANDROID_KEY_ALIAS`: signing alias (for example, `bayantrack`).
- `ANDROID_KEY_PASSWORD`: signing key password.

The workflow pins Flutter 3.38.6 and Java 17, installs locked dependencies,
runs analysis and tests, and builds a signed APK against
`https://api.bayantrack.app/api`. Failed checks prevent publication.
Each successful run creates a separate development prerelease with
`bayantrack.apk` and its SHA-256 checksum.

After committing the workflow and Android configuration to your fork's `main`,
open Actions > Android APK Release. Use Run workflow for a manual rebuild.
Download the APK from Releases and install it manually; GitHub does not update
installed apps automatically.

Build numbers start at 1001 and increase with the workflow run counter.
Keep this workflow's counter intact. If you recreate the workflow, change the
offset so new builds remain above every APK already distributed.

For a local signed release, create the ignored `android/key.properties`:

```properties
storeFile=C:\\Users\\domin\\bayantrack-release.jks
storePassword=<your keystore password>
keyAlias=bayantrack
keyPassword=<your key password>
```

Never commit this file or the keystore. Back up both signing credentials and
the keystore securely. Release builds fail without signing credentials rather
than silently falling back to a debug key. Debug builds need no release key.
An existing debug-signed installation must be uninstalled before switching to
the release-signed APK; uninstalling removes local app data.

## Documentation

- [`../SYSTEM_REFERENCE.md`](../SYSTEM_REFERENCE.md)
- [`../docs/ai-explanations.md`](../docs/ai-explanations.md)
- [`MOBILE_PRIORITIZATION_INTEGRATION.md`](MOBILE_PRIORITIZATION_INTEGRATION.md)
- [`SPEC_MOBILE.md`](SPEC_MOBILE.md)
- [`PERMISSIONS.md`](PERMISSIONS.md)
