# KYC-Based Permissions System

Complete role-based access control (RBAC) based on KYC verification status.

## 📁 Files Created

```
lib/features/auth/
├── data/
│   └── user_permissions.dart           # Permission service & checks
└── presentation/
    └── verification_widgets.dart       # UI prompts & banners
```

## 🔐 Permission Levels

### LIMITED ACCESS USERS
**KYC Status:** `unverified`, `pending`, `rejected`, `resubmit_requested`, `suspended`

**⚠️ IMPORTANT:** All these statuses have **identical permissions** (read-only access).

**🚫 SUSPENDED Status:** Has same permissions as above, but **CANNOT LOGIN**.  
Suspended users are blocked at the authentication layer before reaching the app.

#### ✅ ALLOWED (Read-Only Access)
- Login/Logout (except `suspended` - cannot login)
- View Profile
- Update Profile (name, email)
- Change Password
- Reset Password
- **View All Reports** (read-only, browse only)
- **View Report Details** (read-only)
- **Search/Filter Reports** (read-only)
- **Submit KYC Documents** (except `suspended`)
- **View KYC Status**
- **Resubmit KYC** (if `rejected` or `resubmit_requested`)

#### ❌ BLOCKED
- Create Reports
- Update Reports
- Delete Reports
- Upload Images
- Add Comments
- Export Reports

---

### VERIFIED USERS
**KYC Status:** `verified`

#### ✅ ALLOWED (Full Access)
- Login/Logout
- View Profile
- Update Profile (name, email)
- Change Password
- Reset Password
- View All Reports
- View Report Details
- Search/Filter Reports
- **CREATE Reports** ⭐
- **UPDATE Own Reports** ⭐ (only if status = Pending/Verified)
- **DELETE Own Reports** ⭐ (only if status = Pending)
- **Upload Images** ⭐
- **Add Comments** ⭐
- **Export Reports (CSV/PDF)** ⭐
- View KYC Status

#### ❌ BLOCKED
- Submit KYC (already verified)
- Change Report Status (admin only)
- Approve/Reject KYC (admin only)
- Manage Users (admin only)

---

## 🎯 Permission System Usage

### 1. Check Permissions

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_permissions.dart';

// In your widget
final permissions = ref.watch(userPermissionsProvider);

// Check if user can perform action
if (permissions.hasPermission(UserPermission.createReports)) {
  // Allow action
} else {
  // Show verification prompt
  showVerificationRequiredDialog(
    context,
    permissions,
    'create reports',
  );
}

// Check verification status
if (permissions.isVerified) {
  // Full access
} else {
  // Limited access
}
```

### 2. Available Permission Checks

```dart
enum UserPermission {
  // Basic (always allowed)
  viewProfile,
  updateProfile,
  changePassword,
  resetPassword,
  viewReports,
  viewReportDetails,
  searchReports,
  
  // KYC related
  submitKyc,
  resubmitKyc,
  viewKycStatus,
  
  // Verified user only
  createReports,       // ⭐
  updateOwnReports,    // ⭐
  deleteOwnReports,    // ⭐
  uploadImages,        // ⭐
  addComments,         // ⭐
  exportReports,       // ⭐
}
```

### 3. Get Permission Details

```dart
// Get denial reason
final reason = permissions.getDenialReason(UserPermission.createReports);
// "You must verify your identity to create reports"

// Get status message
final statusMsg = permissions.getStatusMessage();
// "Complete identity verification to unlock all features"

// Get action button text
final buttonText = permissions.getActionButtonText();
// "Verify Identity" or "View Status" or "Resubmit Documents"

// Check advanced permission
final result = permissions.check(UserPermission.createReports);
if (result.isDenied) {
  print(result.denialReason);
}
```

---

## 🎨 UI Components

### 1. Verification Banner
Shows at top of screens for unverified users:

```dart
import '../../auth/presentation/verification_widgets.dart';

Widget build(BuildContext context, WidgetRef ref) {
  final permissions = ref.watch(userPermissionsProvider);
  
  return Scaffold(
    body: Column(
      children: [
        VerificationBanner(permissions: permissions),
        // Your content
      ],
    ),
  );
}
```

### 2. Verification Required Dialog
Shows when user tries blocked action:

```dart
import '../../auth/presentation/verification_widgets.dart';

void _onCreateReport() {
  final permissions = ref.read(userPermissionsProvider);
  
  if (!permissions.hasPermission(UserPermission.createReports)) {
    showVerificationRequiredDialog(
      context,
      permissions,
      'create reports', // Action description
    );
    return;
  }
  
  // Proceed with action
}
```

### 3. Inline Verification Prompt
For replacing blocked features:

```dart
import '../../auth/presentation/verification_widgets.dart';

Widget build(BuildContext context, WidgetRef ref) {
  final permissions = ref.watch(userPermissionsProvider);
  
  if (!permissions.hasPermission(UserPermission.createReports)) {
    return InlineVerificationPrompt(
      permissions: permissions,
      feature: 'create reports',
    );
  }
  
  return YourFeatureWidget();
}
```

---

## 🔄 Implementation Examples

### Example 1: Protect FAB (Create Report Button)

```dart
// lib/features/navigation/main_navigation_shell.dart

void _onFabPressed() {
  final permissions = ref.read(userPermissionsProvider);
  
  if (!permissions.hasPermission(UserPermission.createReports)) {
    showVerificationRequiredDialog(
      context,
      permissions,
      'create reports',
    );
    return;
  }

  // Navigate to new report flow
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NewReportPhotosScreen(),
    ),
  );
}
```

### Example 2: Conditional UI Rendering

```dart
// Show different UI based on verification
Widget build(BuildContext context, WidgetRef ref) {
  final permissions = ref.watch(userPermissionsProvider);
  
  return ListView(
    children: [
      // Always visible
      ViewReportsButton(),
      
      // Only for verified users
      if (permissions.hasPermission(UserPermission.createReports))
        CreateReportButton(),
      
      // Only for unverified
      if (!permissions.isVerified)
        VerifyIdentityButton(),
    ],
  );
}
```

### Example 3: Profile Screen with KYC Status

```dart
// lib/features/auth/presentation/profile_screen.dart

// KYC Status Card is automatically displayed
Consumer(
  builder: (context, ref, _) {
    final kycStatusAsync = ref.watch(kycStatusControllerProvider);
    return kycStatusAsync.when(
      data: (kycStatus) => _buildKycStatusCard(context, ref, kycStatus),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  },
)
```

---

## 📊 Permission Flow Diagram

```
User Attempts Login
     │
     ├─→ KYC Status = suspended
     │   └─→ ❌ LOGIN BLOCKED (handled by backend auth)
     │
     ├─→ Login Successful
     │   └─→ Check KYC Status (kycStatusControllerProvider)
     │
     ├─→ Status = null, unverified, pending, rejected, resubmit_requested
     │   ├─→ Show verification prompt/banner
     │   ├─→ Grant: Read-only access
     │   └─→ Block: Create/Edit/Delete
     │
     └─→ Status = verified
         ├─→ Show "Verified" badge
         ├─→ Grant: Full access
         └─→ Enable: All features ⭐

Note: Suspended users are prevented from logging in by the backend.
If somehow a suspended session exists, they get read-only access.
```

---

## 🚨 Error Handling

### Graceful Degradation

```dart
// Permission checks fail gracefully
final permissions = ref.watch(userPermissionsProvider);

// If KYC status fails to load, defaults to unverified
// User still has read-only access
```

### User-Friendly Messages

```dart
// Clear messages for each status
permissions.getStatusMessage()

// unverified -> "Complete identity verification to unlock all features"
// pending -> "Your verification is pending review..."
// rejected -> "Your verification was rejected. Please resubmit..."
// verified -> "Your identity is verified. You have full access!"
```

---

## 🔧 Integration Checklist

- [x] ✅ **Permissions Service** - Created `user_permissions.dart`
- [x] ✅ **Verification Widgets** - Created banner, dialog, inline prompt
- [x] ✅ **Protected FAB** - Main navigation create button
- [x] ✅ **Protected Screens** - New report flow
- [x] ✅ **Verification Banners** - Home & report screens
- [x] ✅ **Profile KYC Card** - Status display
- [x] ✅ **Image Upload Protection** - Indirect via report creation
- [x] ✅ **Read-Only Reports** - All users can view

---

## 🎯 Testing Scenarios

### Test 1: Unverified User
1. Login with unverified account
2. See verification banner on home
3. Try to click FAB → See verification dialog
4. Click "Verify Identity" → Navigate to KYC form
5. Can view reports but not create

### Test 2: Pending User
1. Login with pending KYC
2. See "Pending Review" banner
3. Try to create report → Blocked with message
4. Click banner → View KYC status screen

### Test 3: Rejected User
1. Login with rejected KYC
2. See rejection reason
3. Click "Resubmit Documents"
4. Pre-filled form with existing data

### Test 4: Verified User
1. Login with verified KYC
2. No banner shown
3. FAB works normally
4. Full access to all features
5. See "Verified" badge in profile

---

## 📝 Key Differences

| Feature | Unverified/Pending/Rejected/Suspended | Verified |
|---------|--------------------------------------|----------|
| **Login** | ✅ All except suspended* | ✅ Allowed |
| **View Reports** | ✅ Read-only | ✅ Full access |
| **Create Reports** | ❌ Blocked | ✅ Allowed |
| **Update Reports** | ❌ Blocked | ✅ Own reports only |
| **Delete Reports** | ❌ Blocked | ✅ Own pending only |
| **Upload Images** | ❌ Blocked | ✅ Allowed |
| **Submit KYC** | ✅ Allowed (except suspended) | ❌ Already verified |
| **Verification Banner** | ✅ Shown | ❌ Hidden |

**\* Suspended users cannot login** - blocked by backend authentication

---

## 🔐 Security Notes

- All checks are client-side UI guards
- Backend must enforce same permissions
- Permissions refresh on KYC status change
- Graceful fallback to unverified if status load fails
- Clear user feedback for all blocked actions

---

## 🚀 Future Enhancements

Potential improvements:
- [ ] Admin role permissions
- [ ] Custom permission sets
- [ ] Feature flags integration
- [ ] Analytics on blocked actions
- [ ] A/B testing for verification prompts
- [ ] Notification when verification completes
