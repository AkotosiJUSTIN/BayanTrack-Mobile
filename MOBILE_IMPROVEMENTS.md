# BayanTrack Mobile - Improvement Backlog

**Document Version:** 1.0  
**Last Updated:** February 14, 2026  
**Status:** Ready for Implementation

---

## 🔴 Critical Issues (P0 - Must Fix)

### 1. Password Reset Flow Navigation Bug

**Issue ID:** `CRITICAL-001`  
**Priority:** P0 - Critical  
**Severity:** High - Security & UX Impact

**Description:**  
When a user initiates a password reset and receives the reset link email, clicking "Login" in the forgot password screen incorrectly navigates them to the homepage without requiring password input. This bypasses the entire password reset mechanism.

**Current Behavior:**
1. User enters email on Forgot Password screen
2. Backend sends reset link to email ✓
3. Success state shows with "Back to Login" link
4. User clicks "Login" text link
5. **BUG**: App navigates to home screen without authentication

**Root Cause Analysis:**
- Location: `lib/features/auth/presentation/forgot_password_screen.dart` (Lines 185-195)
- The `_navigateBack()` method uses `Navigator.pop()` which returns to the previous screen
- If the auth state was somehow cached or the `AuthWrapper` doesn't properly validate session, user gets through
- Missing proper auth state reset after password reset flow

**Expected Behavior:**
- After sending reset email, "Login" should navigate to login screen
- User should complete password reset via email link
- Only after successful password reset can they login
- No automatic navigation to authenticated screens

**Files Affected:**
```
lib/features/auth/presentation/forgot_password_screen.dart
lib/features/auth/presentation/auth_wrapper.dart
lib/features/auth/presentation/auth_controller.dart
```

**Proposed Fix:**
```dart
// In forgot_password_screen.dart
void _navigateBack() {
  // Clear any existing auth state before returning to login
  ref.read(authControllerProvider.notifier).logout();
  
  // Use pushReplacement to prevent back navigation exploits
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}
```

**Additional Considerations:**
- Add auth state validation in `AuthWrapper.initState()`
- Ensure password reset flow properly invalidates existing sessions
- Add integration test for password reset navigation flow

**Testing Requirements:**
- [ ] Test password reset email sending
- [ ] Verify navigation to login screen (not home)
- [ ] Confirm no cached auth state allows bypass
- [ ] Test back button behavior after reset flow
- [ ] Verify proper authentication after password reset

---

### 2. Splash Screen Logo Size Issue

**Issue ID:** `CRITICAL-002`  
**Priority:** P0 - Critical  
**Severity:** Medium - Branding & First Impression

**Description:**  
The app logo appears too small in the native Android splash screen (launch_background.xml), creating a poor first impression. The custom Flutter splash screen in `splash_screen.dart` displays correctly at 200x200dp, but the native Android launch screen doesn't have the logo configured.

**Current State:**
- **Native Splash (Android)**: Blank white/system background - no logo configured
- **Flutter Splash**: Logo displays at 200x200dp with animations ✓
- **Impact**: Users see blank screen flash before Flutter splash appears

**Analysis:**
- Location: `android/app/src/main/res/drawable/launch_background.xml`
- Location: `android/app/src/main/res/drawable-v21/launch_background.xml`
- Both files have commented-out bitmap declarations
- No `launch_image` mipmap assets exist

**Options for Resolution:**

#### **Option A: Enable Native Splash with Proper Logo (Recommended)**
**Pros:**
- Seamless branding from app launch
- Professional appearance
- No flash of blank screen
- Follows Android best practices

**Implementation:**
1. Add logo assets to mipmap folders:
   ```
   android/app/src/main/res/
   ├── mipmap-hdpi/launch_image.png (72x72)
   ├── mipmap-mdpi/launch_image.png (48x48)
   ├── mipmap-xhdpi/launch_image.png (96x96)
   ├── mipmap-xxhdpi/launch_image.png (144x144)
   └── mipmap-xxxhdpi/launch_image.png (192x192)
   ```

2. Update `launch_background.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
       <item android:drawable="@android:color/white" />
       <item>
           <bitmap
               android:gravity="center"
               android:src="@mipmap/launch_image" />
       </item>
   </layer-list>
   ```

3. Update `launch_background-v21.xml` similarly

4. Optional: Add `flutter_native_splash` package for easier management
   ```yaml
   # pubspec.yaml
   dev_dependencies:
     flutter_native_splash: ^2.4.3
   
   # flutter_native_splash.yaml
   flutter_native_splash:
     color: "#FFFFFF"
     image: assets/images/logo.png
     android: true
     ios: true
   ```

#### **Option B: Disable Native Splash (Faster Implementation)**
**Pros:**
- Simpler to implement
- No asset management needed
- Relies entirely on Flutter splash

**Cons:**
- Slight delay before branding appears
- Not following Android best practices
- User sees system splash briefly

**Implementation:**
```xml
<!-- Modify styles.xml -->
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@android:color/white</item>
    <item name="android:windowNoTitle">true</item>
    <item name="android:windowFullscreen">true</item>
    <item name="android:windowDisablePreview">true</item> <!-- Add this -->
</style>
```

**Recommendation:**  
**Use Option A** - Proper native splash implementation maintains professional appearance and follows platform conventions. The `flutter_native_splash` package automates asset generation.

**Files Affected:**
```
android/app/src/main/res/drawable/launch_background.xml
android/app/src/main/res/drawable-v21/launch_background.xml
android/app/src/main/res/values/styles.xml
android/app/src/main/res/mipmap-*/launch_image.png (new files)
pubspec.yaml (if using flutter_native_splash)
```

---

### 3. KYC Rejection Status UI Needs Modernization

**Issue ID:** `UX-001`  
**Priority:** P0 - Critical  
**Severity:** Medium - User Experience Impact

**Description:**  
When admins reject a KYC submission, the rejection status UI on the mobile app lacks visual hierarchy and modern design patterns. Currently displays as a simple red text card with a resubmit button, which:
- Doesn't convey urgency appropriately
- Lacks actionable guidance
- Feels disconnected from the overall app design
- Missing visual feedback for multiple rejection attempts

**Current Design Issues:**

**Location:** `lib/features/kyc/presentation/kyc_status_screen.dart` (Lines 175-205)

```dart
// Current implementation - Basic card with red text
if (kycStatus.rejectionReason != null && kycStatus.rejectionReason!.isNotEmpty)
  Card(
    color: AppColors.alertHigh.withValues(alpha: 0.1),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.alertHigh),
              SizedBox(width: 8),
              Text('Rejection Reason', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(kycStatus.rejectionReason!), // Plain text, no formatting
        ],
      ),
    ),
  ),
```

**Design Problems:**
1. ❌ Generic `info_outline` icon doesn't convey rejection severity
2. ❌ Plain text reason without formatting (no bold/italics for key points)
3. ❌ No visual separation between multiple rejection reasons
4. ❌ Missing contextual help (what to fix, how to resubmit)
5. ❌ Resubmit button appears disconnected from rejection card
6. ❌ No progress indicator for multiple resubmission attempts
7. ❌ Doesn't leverage Material Design 3 components

**Proposed Modern Design:**

```dart
// Modern rejection status card with enhanced UX
if (kycStatus.rejectionReason != null && kycStatus.rejectionReason!.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.alertHigh.withValues(alpha: 0.15),
          AppColors.alertHigh.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.alertHigh.withValues(alpha: 0.3),
        width: 1.5,
      ),
    ),
    child: Column(
      children: [
        // Header with icon and status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.alertHigh.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.alertHigh.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.alertHigh,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Application Rejected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.alertHigh,
                      ),
                    ),
                    if (kycStatus.resubmissionCount > 0)
                      Text(
                        'Attempt ${kycStatus.resubmissionCount + 1} • Please review feedback',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Rejection reason with better formatting
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Feedback',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kycStatus.rejectionReason!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Actionable steps
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Review the feedback and resubmit with corrected documents',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
```

**Additional Enhancements:**

1. **Resubmit Button Enhancement:**
```dart
if (kycStatus.status.canResubmit)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () async { /* existing logic */ },
      icon: const Icon(Icons.refresh_rounded),
      label: Text(
        kycStatus.resubmissionCount > 0
            ? 'Resubmit Documents (Attempt ${kycStatus.resubmissionCount + 1})'
            : 'Resubmit Documents',
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
```

2. **Add Precheck Status Indicator:**
```dart
// Show if precheck notes exist
if (kycStatus.precheckNotes != null && kycStatus.precheckNotes!.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.alertMedium.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.alertMedium.withValues(alpha: 0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: AppColors.alertMedium, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quality Check Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.alertMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kycStatus.precheckNotes!,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
```

**Visual Hierarchy Improvements:**
- ✅ Clear status header with icon and attempt counter
- ✅ Visual separation between admin feedback and actionable steps
- ✅ Gradient background for rejected state draws attention
- ✅ Rounded corners and shadows follow Material Design 3
- ✅ Color-coded sections (rejection = red, tips = blue)
- ✅ Better spacing and padding for readability

**Files Affected:**
```
lib/features/kyc/presentation/kyc_status_screen.dart
lib/features/auth/presentation/verification_widgets.dart (banner also needs update)
lib/core/theme/app_colors.dart (ensure alertHigh/Medium colors are defined)
```

**Testing Requirements:**
- [ ] Test with long rejection reason text (word wrap)
- [ ] Verify color contrast meets WCAG AA standards
- [ ] Test on different screen sizes (small phones, tablets)
- [ ] Check dark mode appearance
- [ ] Verify resubmission counter increments correctly
- [ ] Test with and without precheck notes

---

## 🟡 High Priority Improvements (P1)

### 4. Missing Error Handling for Network Timeouts

**Issue ID:** `BUG-002`  
**Priority:** P1 - High  
**Severity:** Medium

**Description:**  
The app lacks consistent timeout handling for API calls. Long-running operations (image uploads, KYC submission) don't have timeout configurations, potentially leaving users stuck on loading screens.

**Files Affected:**
```
lib/core/network/dio_provider.dart
lib/features/kyc/data/kyc_repository.dart
lib/features/reports/data/reports_repository.dart
lib/features/images/data/image_repository.dart
```

**Recommended Fix:**
```dart
// In dio_provider.dart
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),    // Add
    receiveTimeout: const Duration(seconds: 30),    // Add
    sendTimeout: const Duration(minutes: 5),        // For uploads
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  // Add retry interceptor for transient failures
  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    retries: 3,
    retryDelays: [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 3),
    ],
  ));
  
  return dio;
}
```

---

### 5. Inconsistent Loading States

**Issue ID:** `UX-002`  
**Priority:** P1 - High  
**Severity:** Low

**Description:**  
Loading indicators vary across screens. Some use `CircularProgressIndicator`, others use custom widgets, and some show no loading state at all.

**Examples:**
- Login screen: CircularProgressIndicator ✓
- KYC form: Custom status messages ✓
- Report creation: Mix of both ❌
- Image upload: No progress indicator ❌

**Recommendation:**  
Create a centralized loading widget with optional progress tracking:

```dart
// lib/core/widgets/loading_overlay.dart
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  
  const LoadingOverlay({
    super.key,
    this.message,
    this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null)
                  CircularProgressIndicator(value: progress)
                else
                  const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 6. No Offline Mode Detection

**Issue ID:** `FEATURE-001`  
**Priority:** P1 - High  
**Severity:** Medium

**Description:**  
The app doesn't detect or handle offline scenarios gracefully. Users see cryptic network errors instead of helpful "No Internet Connection" messages.

**Recommended Implementation:**
```dart
// lib/core/providers/connectivity_provider.dart
@riverpod
Stream<ConnectivityResult> connectivity(ConnectivityRef ref) {
  return Connectivity().onConnectivityChanged;
}

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  bool build() {
    final connectivity = ref.watch(connectivityProvider);
    
    connectivity.listen((result) {
      state = result != ConnectivityResult.none;
      
      if (!state) {
        // Show offline banner
      }
    });
    
    return true; // Initial state: assume online
  }
}
```

Add dependency:
```yaml
dependencies:
  connectivity_plus: ^6.2.1
```

---

## 🟢 Medium Priority Enhancements (P2)

### 7. Missing Input Validation Consistency

**Issue ID:** `QA-001`  
**Priority:** P2 - Medium  
**Severity:** Low

**Description:**  
Email validation regex varies across screens. Some forms validate on submit, others on field change. This creates an inconsistent user experience.

**Current State:**
- Login: Validates on submit
- Register: Validates on submit
- Forgot Password: Validates on submit
- Regex patterns: Slightly different across files

**Recommendation:**  
Create centralized validation utilities:

```dart
// lib/core/utils/validators.dart
class Validators {
  // RFC 5322 compliant email regex
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Philippine format: 09XXXXXXXXX or +639XXXXXXXXX
    if (!RegExp(r'^(09|\+639)\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Philippine mobile number';
    }
    return null;
  }
}
```

---

### 8. No Biometric Authentication Option

**Issue ID:** `FEATURE-002`  
**Priority:** P2 - Medium  
**Severity:** Low

**Description:**  
The app requires manual login every time. Adding biometric authentication (fingerprint/face ID) would significantly improve UX for frequent users.

**Recommended Package:**
```yaml
dependencies:
  local_auth: ^2.3.0
```

**Implementation Points:**
- Add biometric toggle in profile settings
- Store encrypted credentials in Flutter Secure Storage
- Fall back to manual login if biometric fails
- Show biometric prompt on app resume (after background)

---

### 9. Image Compression Before Upload

**Issue ID:** `PERF-001`  
**Priority:** P2 - Medium  
**Severity:** Medium

**Description:**  
The app uploads full-resolution images from camera/gallery, leading to:
- Slow upload times on poor networks
- Increased backend storage costs
- Potential mobile data overuse

**Current Behavior:**
```dart
// lib/features/images/data/image_repository.dart
// Images uploaded directly without compression
```

**Recommended Solution:**
```yaml
dependencies:
  flutter_image_compress: ^2.3.0
```

```dart
class ImageRepository {
  Future<String> uploadImage(File imageFile, String folder) async {
    // Compress before upload
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 1920,
      minHeight: 1080,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    
    // Upload compressed image
    // ...existing upload logic
  }
}
```

**Benefits:**
- 70-80% reduction in upload size
- Faster uploads
- Lower bandwidth costs
- Better user experience on slow networks

---

## 🔵 Low Priority / Nice to Have (P3)

### 10. Add Pull-to-Refresh on All List Screens

**Issue ID:** `UX-003`  
**Priority:** P3 - Low

**Description:**  
Only some screens support pull-to-refresh (Home screen ✓). Reports list, notifications, and other list views should also support this gesture.

**Files to Update:**
```
lib/features/reports/presentation/my_reports_screen.dart
lib/features/notifications/presentation/notifications_screen.dart
```

---

### 11. Add App Version Display in Profile

**Issue ID:** `UX-004`  
**Priority:** P3 - Low

**Description:**  
No way for users to see current app version, making debugging user-reported issues difficult.

**Recommended Addition:**
```dart
// In profile_screen.dart, add at bottom:
import 'package:package_info_plus/package_info_plus.dart';

// In build method:
FutureBuilder<PackageInfo>(
  future: PackageInfo.fromPlatform(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.outline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  },
)
```

Add dependency:
```yaml
dependencies:
  package_info_plus: ^8.1.2
```

---

### 12. Implement Dark Mode Toggle

**Issue ID:** `FEATURE-003`  
**Priority:** P3 - Low

**Description:**  
App uses system theme mode but doesn't allow manual override. Some users prefer dark mode even when system is light (or vice versa).

**Current:** ThemeMode.system (hard-coded)  
**Recommended:** User-selectable theme preference

**Implementation:**
```dart
// Add to profile settings
enum ThemePreference { system, light, dark }

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(appPreferencesProvider.notifier);
    final themePref = prefs.getThemePreference();
    
    return switch (themePref) {
      ThemePreference.system => ThemeMode.system,
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
    };
  }
  
  void setTheme(ThemePreference pref) {
    ref.read(appPreferencesProvider.notifier).setThemePreference(pref);
    ref.invalidateSelf();
  }
}
```

---

## 📋 Implementation Priority Matrix

| Priority | Issue Count | Estimated Effort | Impact |
|----------|-------------|------------------|--------|
| P0 - Critical | 3 | 8-12 hours | High |
| P1 - High | 4 | 12-16 hours | Medium-High |
| P2 - Medium | 3 | 8-10 hours | Medium |
| P3 - Low | 3 | 6-8 hours | Low-Medium |

**Total Estimated Effort:** 34-46 hours

---

## 🎯 Recommended Implementation Sequence

### Sprint 1 (P0 Issues)
1. **Week 1:** Fix password reset navigation bug (CRITICAL-001)
2. **Week 1:** Implement native splash screen (CRITICAL-002)
3. **Week 2:** Redesign KYC rejection UI (UX-001)

### Sprint 2 (P1 Issues)
1. **Week 3:** Add timeout handling and retry logic (BUG-002)
2. **Week 3:** Standardize loading states (UX-002)
3. **Week 4:** Implement offline detection (FEATURE-001)
4. **Week 4:** Centralize input validation (QA-001)

### Sprint 3 (P2 Issues)
1. **Week 5:** Add image compression (PERF-001)
2. **Week 6:** Implement biometric auth (FEATURE-002)
3. **Week 6:** Add validation consistency (QA-001 completion)

### Sprint 4 (P3 Nice-to-Haves)
1. **Week 7:** Pull-to-refresh for all lists (UX-003)
2. **Week 7:** App version display (UX-004)
3. **Week 8:** Theme toggle (FEATURE-003)

---

## 📝 Testing Checklist

After implementing each fix:
- [ ] Manual testing on Android device
- [ ] Test on small screen (5" phone)
- [ ] Test on large screen (tablet)
- [ ] Dark mode verification
- [ ] Light mode verification
- [ ] Poor network conditions (throttle to 3G)
- [ ] Offline mode
- [ ] Memory leak check (Android Profiler)
- [ ] Accessibility audit (TalkBack)

---

## 🔗 Related Documentation

- [SPEC_MOBILE.md](./SPEC_MOBILE.md) - Mobile app specification
- [PERMISSIONS.md](./PERMISSIONS.md) - App permissions rationale
- [MOBILE_AI_INTEGRATION.md](./MOBILE_AI_INTEGRATION.md) - AI features documentation

---

## 📞 Questions & Feedback

For questions or suggestions regarding these improvements, contact the development team or create a GitHub issue in the BayanTrack-Mobile repository.

**Last Review:** February 14, 2026  
**Next Review:** After Sprint 2 completion
