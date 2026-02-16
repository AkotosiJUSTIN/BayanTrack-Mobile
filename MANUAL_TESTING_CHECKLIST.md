# 🧪 BayanTrack Mobile — Manual Testing Checklist

**Date:** 2026-02-15  
**Tester:** _______________  
**Device/Emulator:** _______________  
**OS Version:** _______________  
**App Build:** _______________  

> Mark each item: ✅ Pass | ❌ Fail | ⏭️ Skipped  
> Add notes in the **Notes** column for any failures or observations.

---

## 1. CRITICAL-001: Password Reset Flow Navigation

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 1.1 | Navigate to Forgot Password | Login screen → Tap "Forgot Password?" | Forgot Password screen opens | ☐ | |
| 1.2 | Submit valid email | Enter valid email → Tap "Send Reset Link" | Success message appears, "Email sent" UI shown | ☐ | |
| 1.3 | Tap "Back to Login" after reset | After email sent → Tap "Back to Login" | Navigates to Login screen (not Home) | ☐ | |
| 1.4 | Back button after "Back to Login" | After navigating to Login → Press device back button | Should NOT return to Forgot Password screen (pushReplacement prevents it) | ☐ | |
| 1.5 | Auth state cleared | After returning to Login → Check that no user session is active | Login screen shows (not auto-logged in) | ☐ | |
| 1.6 | Submit invalid email | Enter "notanemail" → Tap "Send Reset Link" | Validation error: "Please enter a valid email" | ☐ | |
| 1.7 | Submit empty email | Leave email empty → Tap "Send Reset Link" | Validation error: "Email is required" | ☐ | |

---

## 2. CRITICAL-002: Native Splash Screen

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 2.1 | Splash screen appears on cold start | Kill app completely → Reopen | Native splash screen with logo appears before Flutter renders | ☐ | |
| 2.2 | Logo is centered | Observe splash screen | Logo is centered on screen, not stretched or cropped | ☐ | |
| 2.3 | Light mode splash | Set device to light mode → Cold start | White background with centered logo | ☐ | |
| 2.4 | Dark mode splash | Set device to dark mode → Cold start | Dark background (#0F172A) with centered logo | ☐ | |
| 2.5 | Transition to app | Wait for Flutter to load | Smooth transition from splash to app content (no flash) | ☐ | |

> **Pre-requisite:** Run `flutter pub run flutter_native_splash:create` before testing this section.

---

## 3. UX-001: KYC Rejection Status UI

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 3.1 | Rejection card gradient | Have a rejected KYC → Open KYC Status screen | Red gradient container with rounded corners and border visible | ☐ | |
| 3.2 | Rejection header | Observe "Application Rejected" header area | Circular red icon badge with cancel icon, bold "Application Rejected" title | ☐ | |
| 3.3 | Attempt counter | Have resubmissionCount > 0 | Shows "Attempt X • Please review feedback" subtitle | ☐ | |
| 3.4 | Admin feedback section | Check rejection reason area | "Admin Feedback" label with the reason in a surface-colored container | ☐ | |
| 3.5 | Actionable tip | Check below rejection reason | Blue tip box with lightbulb icon: "Review the feedback and resubmit..." | ☐ | |
| 3.6 | Precheck notes | Have precheckNotes set on KYC entity | Yellow warning box with "Quality Check Notes" and the note text | ☐ | |
| 3.7 | No precheck notes | precheckNotes is null/empty | No warning box shown | ☐ | |
| 3.8 | Resubmit button | Tap "Resubmit Documents" button | Navigates to KYC form with isResubmission=true | ☐ | |
| 3.9 | Resubmit button styling | Observe button appearance | Primary color background, white text, refresh icon, rounded corners | ☐ | |
| 3.10 | Resubmit with attempts | resubmissionCount > 0 | Button text reads "Resubmit Documents (Attempt X)" | ☐ | |

---

## 4. BUG-002: Network Timeout Handling

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 4.1 | Normal API call | Make any API request on good connection | Request completes successfully within 30s | ☐ | |
| 4.2 | Slow connection (connect) | Enable network throttling / airplane mode briefly | Connection timeout after ~30s with error message (not infinite hang) | ☐ | |
| 4.3 | Slow response (receive) | Simulate slow server response | Receive timeout after ~30s with error message | ☐ | |
| 4.4 | File upload timeout | Upload a large image on slow connection | Upload allowed up to 5 minutes before timeout | ☐ | |
| 4.5 | Timeout error message | Trigger any timeout | User-friendly error shown (not raw DioException) | ☐ | |

---

## 5. UX-002: Loading Overlay Widget

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 5.1 | Widget exists | Import `LoadingOverlay` from `core/presentation/widgets/loading_overlay.dart` | No import errors | ☐ | |
| 5.2 | Indeterminate loading | Use `LoadingOverlay(message: 'Loading...')` | Dark semi-transparent overlay with spinning indicator and message | ☐ | |
| 5.3 | Progress loading | Use `LoadingOverlay(message: 'Uploading...', progress: 0.5)` | Shows progress indicator at 50% with percentage text | ☐ | |
| 5.4 | No message | Use `LoadingOverlay()` | Spinner only, no text below | ☐ | |

> **Note:** This widget is available for use but may not yet be integrated into all screens. Test where integrated.

---

## 6. FEATURE-001: Offline Mode Detection

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 6.1 | Online state (default) | Open app with internet connected | No offline banner visible | ☐ | |
| 6.2 | Go offline | Turn on Airplane Mode or disable WiFi/data | Red banner appears: "No Internet Connection" with wifi_off icon | ☐ | |
| 6.3 | Come back online | Re-enable internet | Red banner disappears | ☐ | |
| 6.4 | Banner on Profile screen | Go offline while on Profile screen | Offline banner appears at the top of the screen (below app bar) | ☐ | |
| 6.5 | Toggle rapidly | Turn connection on/off quickly several times | Banner state follows connection state without crashes | ☐ | |
| 6.6 | App start while offline | Start app with no internet | Offline banner visible immediately (or shortly after) | ☐ | |

---

## 7. QA-001: Centralized Input Validation

### 7a. Login Screen

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 7a.1 | Empty email | Leave email empty → Submit | "Email is required" | ☐ | |
| 7a.2 | Invalid email (no @) | Enter "testgmail.com" → Submit | "Please enter a valid email" | ☐ | |
| 7a.3 | Invalid email (no domain) | Enter "test@" → Submit | "Please enter a valid email" | ☐ | |
| 7a.4 | Valid email | Enter "test@gmail.com" → Submit | No email validation error | ☐ | |

### 7b. Register Screen

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 7b.1 | Empty email | Leave email empty → Submit | "Email is required" | ☐ | |
| 7b.2 | Invalid email | Enter "bad-email" → Submit | "Please enter a valid email" | ☐ | |
| 7b.3 | Valid email | Enter "user@example.com" → Submit | No email validation error | ☐ | |
| 7b.4 | Empty first name | Leave first name empty → Submit | "Please enter your first name" | ☐ | |
| 7b.5 | Empty last name | Leave last name empty → Submit | "Please enter your last name" | ☐ | |
| 7b.6 | Short password | Enter 5-char password → Submit | "Password must be at least 8 characters" | ☐ | |
| 7b.7 | Mismatched passwords | Enter different confirm password → Submit | "Passwords do not match" | ☐ | |

### 7c. Forgot Password Screen

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 7c.1 | Empty email | Leave email empty → Tap Send | "Email is required" | ☐ | |
| 7c.2 | Invalid email | Enter "not.an" → Tap Send | "Please enter a valid email" | ☐ | |
| 7c.3 | Valid email | Enter "valid@test.com" → Tap Send | No validation error, request proceeds | ☐ | |

### 7d. Consistency Check

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 7d.1 | Same invalid email across screens | Try "test@x" on Login, Register, Forgot Password | Same validation message on ALL screens | ☐ | |
| 7d.2 | Same valid email across screens | Try "user@domain.co" on all screens | Accepted on ALL screens | ☐ | |

---

## 8. UX-004: App Version Display in Profile

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 8.1 | Version visible | Navigate to Profile screen → Scroll to bottom | "Version X.Y.Z (buildNumber)" text visible below menu | ☐ | |
| 8.2 | Version text styling | Observe version text | Small, gray, centered text | ☐ | |
| 8.3 | Correct version | Compare to `pubspec.yaml` version | Matches the version defined in project config | ☐ | |

---

## 9. FEATURE-003: Dark Mode Toggle

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 9.1 | Theme menu item visible | Navigate to Profile → Check menu | "Theme" item with icon and current mode subtitle visible | ☐ | |
| 9.2 | Default is System | Fresh install → Check theme item | Shows "System Default" with `brightness_auto` icon | ☐ | |
| 9.3 | Toggle to Light | Tap Theme menu item once (from System) | Switches to "Light Mode" with `light_mode` icon, app theme changes | ☐ | |
| 9.4 | Toggle to Dark | Tap Theme item again (from Light) | Switches to "Dark Mode" with `dark_mode` icon, app goes dark | ☐ | |
| 9.5 | Toggle to System | Tap Theme item again (from Dark) | Returns to "System Default", follows OS setting | ☐ | |
| 9.6 | Theme persists on restart | Set to Dark → Kill app → Reopen | App opens in Dark mode (preference saved) | ☐ | |
| 9.7 | Theme applies to all screens | Switch to Dark → Navigate to Login, KYC, Reports, etc. | All screens render in dark theme consistently | ☐ | |

---

## 10. Verification Widgets (Banner Icons)

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 10.1 | Unverified banner | KYC status = unverified | Shield icon shown with amber color | ☐ | |
| 10.2 | Pending banner | KYC status = pending | Hourglass icon shown with amber color | ☐ | |
| 10.3 | Rejected banner | KYC status = rejected | Cancel icon shown with red color | ☐ | |
| 10.4 | Resubmit requested banner | KYC status = resubmitRequested | Refresh icon shown with red color | ☐ | |
| 10.5 | Suspended banner | KYC status = suspended | Block icon shown with red color | ☐ | |
| 10.6 | Verified banner | KYC status = verified | Verified user icon with green color (or banner hidden) | ☐ | |

---

## 11. Auth Wrapper Session Validation

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 11.1 | Fresh login | Login with valid credentials | Navigates to main app, session active | ☐ | |
| 11.2 | App restart with valid session | Login → Kill app → Reopen | App restores session, user stays logged in | ☐ | |
| 11.3 | App restart with expired session | Wait for token to expire → Reopen app | Session is validated, user may be redirected to login | ☐ | |
| 11.4 | Logout clears session | Tap Logout → Confirm → Reopen app | Login screen shown, no auto-login | ☐ | |

---

## 12. Regression Checks

| # | Test Case | Steps | Expected Result | Status | Notes |
|---|-----------|-------|-----------------|--------|-------|
| 12.1 | Login flow works | Enter valid credentials → Tap Login | User logs in successfully | ☐ | |
| 12.2 | Registration flow works | Fill all fields → Tap Create Account | Account created, user logged in | ☐ | |
| 12.3 | Report creation works | Create new report with images | Report submitted successfully | ☐ | |
| 12.4 | Notifications load | Navigate to Notifications tab | Notifications list loads | ☐ | |
| 12.5 | Pull-to-refresh on Reports | Pull down on My Reports screen | Reports refresh without error | ☐ | |
| 12.6 | Pull-to-refresh on Notifications | Pull down on Notifications screen | Notifications refresh without error | ☐ | |
| 12.7 | Pull-to-refresh on Profile | Pull down on Profile screen | Profile data refreshes | ☐ | |
| 12.8 | KYC form submission | Submit KYC with all required fields | KYC submitted, status updates | ☐ | |
| 12.9 | Image upload | Attach image to report | Image uploads without timeout on normal network | ☐ | |
| 12.10 | Edit profile works | Change name → Save | Profile updated successfully | ☐ | |
| 12.11 | Change password works | Enter old + new password → Save | Password changed, can login with new password | ☐ | |

---

## Summary

| Section | Total Tests | Passed | Failed | Skipped |
|---------|-------------|--------|--------|---------|
| 1. Password Reset Flow | 7 | | | |
| 2. Native Splash Screen | 5 | | | |
| 3. KYC Rejection UI | 10 | | | |
| 4. Network Timeouts | 5 | | | |
| 5. Loading Overlay | 4 | | | |
| 6. Offline Detection | 6 | | | |
| 7. Input Validation | 13 | | | |
| 8. App Version Display | 3 | | | |
| 9. Dark Mode Toggle | 7 | | | |
| 10. Verification Banners | 6 | | | |
| 11. Auth Session | 4 | | | |
| 12. Regression | 11 | | | |
| **TOTAL** | **81** | | | |

---

**Sign-off:**  
Tested by: _______________ Date: _______________  
Reviewed by: _______________ Date: _______________
