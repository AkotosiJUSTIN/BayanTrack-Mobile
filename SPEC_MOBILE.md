# BayanTrack Mobile Specification

## 1. Architectural Overview
**Style**: Clean Architecture (Domain-Driven Design) + MVVM.
**Framework**: Flutter.

### Layers
1.  **Presentation (UI)**: 
    *   **Screens/Widgets**: Pure UI components, no business logic.
    *   **Controllers** (`AsyncNotifier`): Manage UI state, handle user input, call Use Cases.
2.  **Domain (Business Logic)**: 
    *   **Entities**: Pure Dart classes (e.g., `User`, `Report`).
    *   **Use Cases**: Single-responsibility classes encapsulating business rules (e.g., `LoginUseCase`, `SubmitReportUseCase`).
    *   **Repository Interfaces**: Abstract definitions of data operations.
    *   **Failures**: Domain-specific error handling.
3.  **Data (Infrastructure)**: 
    *   **Repository Implementations**: Implement domain interfaces.
    *   **Mappers**: Convert between DTOs and Domain Entities.
    *   **Data Sources**: API Clients (Dio), secure token storage, preferences, and app-owned staged files.
    *   **DTOs**: Data Transfer Objects with JSON serialization.
4.  **Core**: Shared utilities, constants, and dependency injection setup.

## 2. Technology Stack
*   **Core**: Flutter 3.x (Dart 3.x).
*   **State Management**: Riverpod (`riverpod_annotation` + `flutter_riverpod`).
*   **Code Generation**: `build_runner`, `freezed` (immutable state), `json_serializable`.
*   **Networking**: Dio (HTTP Client) with centralized `AuthInterceptor` and `ErrorMapper`.
*   **Error Handling**: Functional `Result<T>` pattern (`Success` or `Failure`).
*   **Local Storage**: `flutter_secure_storage` for auth tokens; `shared_preferences` plus app-owned files for non-secret durable upload intents.

## 3. Feature Specifications

### 3.1 Authentication
*   **Architecture**: Domain-driven with strict Use Case separation (`LoginUseCase`, `RegisterUseCase`).
*   **Flow**: Controller -> Use Case -> Repository -> Dio.
*   **Security**: Token-based auth (Access/Refresh), auto-refresh via Interceptor.
*   **Storage**: Secure storage for tokens, `keepAlive` providers for session persistence.

### 3.2 KYC (Know Your Customer)
*   **Status Management**: Tracks `unverified`, `pending`, `verified`, `rejected`.
*   **Form Logic**: Multi-step form with validation for ID types, images, and personal info.
*   **Data Models**: Separate Domain Enums (pure Dart) vs API Strings.
*   **Validation**: Client-side validation for image sizes and required fields before API call.

### 3.3 Notifications
*   **Structure**: Paginated list of notifications (`PaginatedNotifications`).
*   **Types**: Strongly typed `NotificationType` enum (system, report_update, account).
*   **Preferences**: Toggleable settings for push/email/sms notifications.
*   **Clean Architecture**: Mapper converts raw JSON API response to Domain Entities.

### 3.4 Reports (Incident Tracking)
*   **Entities**: `Report` entity with rich metadata (severity, location, images).
*   **Flow**: Create the report once, then persist and upload each evidence item against the returned report ID.
*   **Durable Evidence Uploads**: After report creation succeeds, each item is copied to app-owned storage and recorded as an owner-scoped intent with a stable idempotency key. Intents use `pending`, `uploading`, `retry waiting`, `completed`, `failed`, `missing local file`, and `dismissed` states.
*   **Recovery**: Matching authenticated users resume eligible intents on startup, app resume, and safe reconnect. Automatic retries use bounded backoff; failed items also support manual retry. Logout and account changes pause, rather than transfer, another user's intents.
*   **Safety**: Evidence retry replays only the existing upload endpoint and stable idempotency key; it never recreates the report. Staged files are removed only after upload completion or explicit dismissal.
*   **State**: `ReportsController` manages fetching, filtering, and pagination.

## 4. State Management Strategy (Riverpod)
*   **Dependency Injection**: All repositories and use cases are provided via Riverpod.
*   **Controller Pattern**: 
    *   Extend `_$MyController` (Riverpod Generator).
    *   Expose immutable state (using `freezed`).
    *   Methods mutate state via `state = AsyncValue...`.
*   **Lifecycle**: `keepAlive: true` used for singleton-like services (AuthSession).

## 5. Security & Performance
*   **Secure Storage**: Tokens stored in EncryptedSharedPreferences (Android) / Keychain (iOS).
*   **Null Safety**: Strict null safety across all layers.
*   **Immutability**: Freezed classes prevent accidental mutations.
*   **DTO/Entity Separation**: API changes don't break UI code; only Mappers need updates.
