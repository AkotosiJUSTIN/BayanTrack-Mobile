# KYC Implementation - BayanTrack Mobile

Complete KYC (Know Your Customer) verification feature for identity verification.

## 📁 File Structure

```
lib/features/kyc/
├── data/
│   ├── kyc_models.dart           # Data models and enums
│   ├── kyc_models.freezed.dart   # Generated freezed code
│   ├── kyc_models.g.dart         # Generated JSON serialization
│   └── kyc_repository.dart       # API calls and validation
└── presentation/
    ├── kyc_controller.dart       # State management
    ├── kyc_controller.g.dart     # Generated riverpod code
    ├── kyc_status_screen.dart    # View KYC status
    └── kyc_form_screen.dart      # Submit/resubmit KYC
```

## 🔌 API Endpoints

All endpoints are configured in `lib/core/constants/api_constants.dart`:

- `GET /api/auth/kyc/id-types/` - Get valid ID types
- `POST /api/auth/kyc/submit/` - Submit KYC documents
- `GET /api/auth/kyc/status/` - Get KYC status
- `POST /api/auth/kyc/resubmit/` - Resubmit after rejection

## 📝 Data Models

### KycStatus Enum
```dart
enum KycStatus {
  unverified,           // No KYC submitted - can submit
  pending,              // Awaiting admin review - read-only
  verified,             // Approved by admin - full access ⭐
  rejected,             // Rejected by admin - can resubmit
  resubmitRequested,    // Admin requested resubmission - can resubmit
  suspended,            // Account suspended - CANNOT LOGIN ⚠️
}
```

**Permission Groups:**
- **Limited Access** (read-only): `unverified`, `pending`, `rejected`, `resubmitRequested`, `suspended`
- **Full Access**: `verified`

**⚠️ Note:** `suspended` users should be prevented from logging in at the backend authentication level.

### IdType Enum
```dart
enum IdType {
  passport,
  nationalId,
  driversLicense,
  philsys,
  sss,
  umid,
  postal,
  voters,
}
```

### KycSubmitRequest
```dart
class KycSubmitRequest {
  final IdType idType;           // Required
  final String? idNumber;        // Optional
  final String fullName;         // Required
  final String? dateOfBirth;     // Optional (YYYY-MM-DD)
  final String idImagePath;      // Required (front of ID)
  final String? idBackImagePath; // Conditional (some IDs require)
  final String selfieImagePath;  // Required
}
```

### KycStatusResponse
Contains all KYC information including:
- Status, ID type, personal info
- Image URLs for uploaded documents
- Precheck status and admin notes
- Rejection reason (if rejected)
- Verification details and timestamps

## 🎨 UI Screens

### 1. KycStatusScreen
- Shows current verification status
- Displays submitted information
- Shows rejection reasons
- Allows resubmission if rejected

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const KycStatusScreen(),
  ),
);
```

### 2. KycFormScreen
- ID type selection dropdown
- Personal information form
- Image pickers (camera/gallery)
- Form validation
- Image size validation (max 10MB)

**Usage:**
```dart
// New submission
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const KycFormScreen(),
  ),
);

// Resubmission
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => KycFormScreen(
      isResubmission: true,
      existingKyc: kycStatus,
    ),
  ),
);
```

## 🔧 State Management

### Providers

**KycStatusController** - Manages KYC status
```dart
final kycStatusAsync = ref.watch(kycStatusControllerProvider);

// Refresh status
ref.read(kycStatusControllerProvider.notifier).refresh();
```

**IdTypesProvider** - Fetches available ID types
```dart
final idTypesAsync = ref.watch(idTypesProvider);
```

**KycFormController** - Manages form state
```dart
final state = ref.watch(kycFormControllerProvider);
final controller = ref.read(kycFormControllerProvider.notifier);

// Set values
controller.setIdType(IdType.passport);
controller.setFullName('John Doe');
controller.setIdImage('/path/to/image.jpg');

// Submit
await controller.submitKyc();
await controller.resubmitKyc();
```

## 📸 Image Requirements

- **Formats:** JPG, PNG
- **Max size:** 10MB per image
- **Required:** ID front + Selfie
- **Conditional:** ID back (for national ID, driver's license, PhilSys, UMID)

The repository automatically validates image sizes before submission.

## 🔐 Validation

### Form Validation
- ID type selected
- Full name provided
- ID front image uploaded
- Selfie image uploaded
- ID back image (if ID type requires it)

### Image Validation
- Maximum 10MB per file
- Validated before API submission
- Clear error messages for size violations

## 📊 Status Flow

```
unverified → pending → verified
                ↓
           rejected → resubmit_requested → pending
                ↓
           suspended
```

## 🎯 Usage Example

### Check and Display KYC Status
```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatusAsync = ref.watch(kycStatusControllerProvider);
    
    return kycStatusAsync.when(
      data: (kycStatus) {
        if (kycStatus == null) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KycFormScreen(),
                ),
              );
            },
            child: const Text('Verify Identity'),
          );
        }
        
        return ListTile(
          title: const Text('KYC Status'),
          subtitle: Text(kycStatus.kycStatus.displayName),
          trailing: Icon(
            kycStatus.kycStatus == KycStatus.verified
                ? Icons.check_circle
                : Icons.pending,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KycStatusScreen(),
              ),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 🚨 Error Handling

Common errors are handled with user-friendly messages:
- Invalid ID type
- File too large (>10MB)
- KYC already submitted
- Network errors
- Missing required fields

Errors are displayed via:
- SnackBars for submission feedback
- Form validation messages
- Error states in async data

## 🔄 Refresh Pattern

The KYC status is automatically refreshed when:
- Navigating to KYC status screen
- After successful submission
- Manual refresh button pressed

```dart
// Manual refresh
ref.read(kycStatusControllerProvider.notifier).refresh();

// Invalidate and refetch
ref.invalidate(kycStatusControllerProvider);
```

## 📦 Dependencies

Required packages (already in `pubspec.yaml`):
- `flutter_riverpod` - State management
- `freezed_annotation` - Immutable models
- `json_annotation` - JSON serialization
- `dio` - HTTP client
- `image_picker` - Camera/gallery access

## 🎨 Theme Integration

Uses app theme colors from `lib/core/theme/app_colors.dart`:
- `AppColors.success` - Verified status
- `AppColors.alertMedium` - Pending status
- `AppColors.alertHigh` - Rejected status
- `AppColors.textSecondary` - Secondary text

## 📱 Platform Support

- ✅ Android (uses image_picker)
- ✅ iOS (uses image_picker)
- ⚠️ Web (image_picker has limited support)

## 🔒 Security Notes

- All API calls require authentication (Bearer token)
- Images are validated client-side before upload
- Server-side validation is primary security layer
- Personal information is transmitted securely via HTTPS

## 🚀 Future Enhancements

Potential improvements:
- [ ] Image compression before upload
- [ ] OCR for automatic ID number extraction
- [ ] Face matching validation
- [ ] Document quality checks
- [ ] Multiple document upload for additional verification
- [ ] Push notifications for status updates
