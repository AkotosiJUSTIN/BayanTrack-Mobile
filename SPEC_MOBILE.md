# BayanTrack Mobile Specification

## 1. Architectural Overview
**Style**: Layered Architecture + MVVM-style Presentation.
**Framework**: Flutter.

### Layers
1.  **Presentation (UI)**: Screens and Widgets. Reacts to state changes provided by ViewModels/Providers.
2.  **Application (State/ViewModel)**: Riverpod Providers managing UI state and business logic orchestration.
3.  **Domain (Model)**: Pure Dart classes representing entities (Reports, Users).
4.  **Infrastructure (Data)**: Repositories implementing API calls, local database (caching), and device services (Camera, GPS).

## 2. Technology Stack
*   **Core**: Flutter (Dart).
*   **State Management**: Riverpod.
    *   *Pattern*: `NotifierProvider` / `AsyncNotifierProvider` for MVVM-style logic.
*   **Networking**: Dio (HTTP Client) + Retrofit (Optional).
*   **Local Storage**: Hive or Isar (Offline-first caching).
*   **Maps**: Google Maps Flutter or Flutter Map (OSM).

## 3. Feature Specifications

### 3.1 Authentication
*   **Flow**: Login Screen -> Provider Authentication -> Token Storage (Flutter Secure Storage).
*   **Biometrics**: Optional Local Auth (FaceID/TouchID) for quick re-entry.

### 3.2 Reporting Workflow (The Core Loop)
1.  **Capture**: Camera Stream -> Capture Image -> Compress.
2.  **Locate**: Geolocator -> Get Lat/Lng -> Reverse Geocode (Address).
3.  **Compose**: Form input (Description, Type).
4.  **Submit**:
    *   *Online*: Upload Media -> POST Data -> Success.
    *   *Offline*: Save to Hive `DraftsBox` -> Background Sync when online.

### 3.3 Dashboard & Maps
*   **Map View**: Pins for nearby incidents. Filter by status/category.
*   **List View**: Infinite scroll list of reports.
*   **Detail View**: Hero animation for images, status timeline.

## 4. State Management Strategy (Riverpod)
*   **Services**: `authServiceProvider`, `reportRepositoryProvider`.
*   **View Logic**:
    *   `authControllerProvider`: Handles login/register logic and loading states.
    *   `reportListProvider`: Manages the list of fetched reports (pagination, filtering).
    *   `reportFormNotifier`: Manages the state of a report currently being written (draft).

## 5. Security & Performance
*   **Secure Storage**: Never store JWTs in plain SharedPreferences. Use `flutter_secure_storage`.
*   **Permissions**: Request GPS/Camera permissions strictly when needed.
*   **Image Optimization**: Compress images on-device using `flutter_image_compress` before upload to save bandwidth.