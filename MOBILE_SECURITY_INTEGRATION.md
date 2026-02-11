# Mobile Security Integration Guide

**Date:** February 11, 2026  
**Backend Security Phases:** 5/5 Complete (147/147 tests passing)  
**Mobile Integration Status:** ⚠️ **MFA Support Required**

## Overview

This document outlines required changes to the BayanTrack Flutter mobile app to support the backend security enhancements implemented in Phases 1-5. Most features are transparent to the mobile app, but **Multi-Factor Authentication (MFA)** requires significant UI/UX changes.

---

## 📋 Integration Summary by Phase

| Phase | Backend Feature | Mobile Changes Required | Priority |
|-------|----------------|------------------------|----------|
| Phase 1 | Input Sanitization | ✅ None (backend middleware) | N/A |
| Phase 2 | Audit Logging | ✅ None (server-side only) | N/A |
| Phase 3 | Field Encryption | ✅ None (transparent encryption) | N/A |
| **Phase 4** | **MFA Implementation** | **⚠️ REQUIRED** | **HIGH** |
| Phase 5 | Data Retention | ✅ None (admin feature) | N/A |

---

## ✅ Phase 1: Input Sanitization - No Changes Required

**Backend Implementation:** Middleware automatically sanitizes all incoming requests

**Mobile Impact:** 
- ✅ No changes needed
- Backend sanitizes input before processing
- Existing form validation on mobile remains unchanged

**Testing:**
- Existing mobile forms continue to work
- Backend blocks malicious input (XSS, SQL injection)

---

## ✅ Phase 2: Audit Logging - No Changes Required

**Backend Implementation:** All authentication and authorization events are logged server-side

**Mobile Impact:**
- ✅ No changes needed
- Login/logout/access events automatically logged on backend
- No additional API calls required

**Benefits:**
- User activity tracked for security
- Admin can audit suspicious behavior
- Transparent to mobile users

---

## ✅ Phase 3: Field Encryption - No Changes Required

**Backend Implementation:** PII fields (phone, address, GPS) encrypted at rest

**Mobile Impact:**
- ✅ No changes needed
- Backend encrypts data before storage
- Backend decrypts data before sending to mobile
- Mobile app sees plain text (no encryption/decryption logic needed)

**Encrypted Fields:**
- User phone numbers
- User addresses
- Report GPS coordinates

**Testing:**
- Verify phone numbers display correctly in profile
- Verify addresses display correctly
- Verify report locations appear correctly on map

---

## ⚠️ Phase 4: MFA Implementation - **CHANGES REQUIRED**

**Backend Implementation:** TOTP-based MFA with QR codes and backup codes

**Mobile Impact:** 🚨 **SIGNIFICANT CHANGES REQUIRED**

### Required Changes

#### 1. Update Login Flow

**Current Flow:**
```
LoginScreen → login() → Success → Navigate to Main
```

**New Flow:**
```
LoginScreen → login() → Check mfa_required
  ├─ No MFA → Success → Navigate to Main
  └─ MFA Required → Navigate to MFAVerifyScreen → verify() → Success → Navigate to Main
```

**File:** `lib/features/auth/presentation/login_screen.dart`

**Changes Needed:**
- Update `_handleLogin()` to check for `mfa_required` response
- Navigate to MFA verification screen if MFA is required
- Pass `user_id` to MFA verification screen

#### 2. Create MFA Data Models

**New File:** `lib/features/auth/data/mfa_models.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mfa_models.freezed.dart';
part 'mfa_models.g.dart';

/// Response when MFA is required during login
@freezed
class MFARequiredResponse with _$MFARequiredResponse {
  const factory MFARequiredResponse({
    required bool mfaRequired,
    required String userId,
    required String message,
  }) = _MFARequiredResponse;

  factory MFARequiredResponse.fromJson(Map<String, dynamic> json) =>
      _$MFARequiredResponseFromJson(json);
}

/// Request to verify MFA token
@freezed
class MFAVerifyRequest with _$MFAVerifyRequest {
  const factory MFAVerifyRequest({
    required String userId,
    required String token,
  }) = _MFAVerifyRequest;

  factory MFAVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$MFAVerifyRequestFromJson(json);
}

/// Response from MFA setup (includes QR code and secret)
@freezed
class MFASetupResponse with _$MFASetupResponse {
  const factory MFASetupResponse({
    required String secret,
    required String qrCode, // base64 encoded PNG
    required String message,
  }) = _MFASetupResponse;

  factory MFASetupResponse.fromJson(Map<String, dynamic> json) =>
      _$MFASetupResponseFromJson(json);
}

/// Response from MFA enable (includes backup codes)
@freezed
class MFAEnableResponse with _$MFAEnableResponse {
  const factory MFAEnableResponse({
    required String message,
    required List<String> backupCodes,
  }) = _MFAEnableResponse;

  factory MFAEnableResponse.fromJson(Map<String, dynamic> json) =>
      _$MFAEnableResponseFromJson(json);
}

/// MFA status response
@freezed
class MFAStatusResponse with _$MFAStatusResponse {
  const factory MFAStatusResponse({
    required bool enabled,
    required int backupCodesRemaining,
  }) = _MFAStatusResponse;

  factory MFAStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$MFAStatusResponseFromJson(json);
}
```

#### 3. Update API Constants

**File:** `lib/core/constants/api_constants.dart`

**Add MFA endpoints:**
```dart
// MFA Endpoints
static const String mfaSetup = '/auth/mfa/setup/';
static const String mfaEnable = '/auth/mfa/enable/';
static const String mfaVerify = '/auth/mfa/verify/';
static const String mfaDisable = '/auth/mfa/disable/';
static const String mfaStatus = '/auth/mfa/status/';
static const String mfaRegenerateBackup = '/auth/mfa/regenerate-backup/';
```

#### 4. Update Auth Repository

**File:** `lib/features/auth/domain/auth_repository.dart`

**Add MFA methods:**
```dart
/// MFA Methods

/// Setup MFA (get QR code)
Future<Result<MFASetupResponse>> setupMFA();

/// Enable MFA with verification token
Future<Result<MFAEnableResponse>> enableMFA(String token);

/// Verify MFA token during login
Future<Result<AuthTokens>> verifyMFA({
  required String userId,
  required String token,
});

/// Disable MFA
Future<Result<void>> disableMFA(String token);

/// Get MFA status
Future<Result<MFAStatusResponse>> getMFAStatus();

/// Regenerate backup codes
Future<Result<List<String>>> regenerateBackupCodes(String token);
```

**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Implement MFA methods:**
```dart
@override
Future<Result<MFASetupResponse>> setupMFA() async {
  try {
    final response = await _dio.post(ApiConstants.mfaSetup);
    final setup = MFASetupResponse.fromJson(response.data);
    return Success(setup);
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}

@override
Future<Result<MFAEnableResponse>> enableMFA(String token) async {
  try {
    final response = await _dio.post(
      ApiConstants.mfaEnable,
      data: {'token': token},
    );
    final enable = MFAEnableResponse.fromJson(response.data);
    return Success(enable);
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}

@override
Future<Result<AuthTokens>> verifyMFA({
  required String userId,
  required String token,
}) async {
  try {
    final response = await _dio.post(
      ApiConstants.mfaVerify,
      data: MFAVerifyRequest(userId: userId, token: token).toJson(),
    );
    final loginResponse = LoginResponse.fromJson(response.data);
    return Success(AuthMapper.tokensFromLoginResponse(loginResponse));
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}

@override
Future<Result<void>> disableMFA(String token) async {
  try {
    await _dio.post(
      ApiConstants.mfaDisable,
      data: {'token': token},
    );
    return const Success(null);
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}

@override
Future<Result<MFAStatusResponse>> getMFAStatus() async {
  try {
    final response = await _dio.get(ApiConstants.mfaStatus);
    final status = MFAStatusResponse.fromJson(response.data);
    return Success(status);
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}

@override
Future<Result<List<String>>> regenerateBackupCodes(String token) async {
  try {
    final response = await _dio.post(
      ApiConstants.mfaRegenerateBackup,
      data: {'token': token},
    );
    final codes = List<String>.from(response.data['backup_codes']);
    return Success(codes);
  } catch (e, stack) {
    return Err(ErrorMapper.mapException(e, stack));
  }
}
```

#### 5. Update Auth Controller

**File:** `lib/features/auth/presentation/auth_controller.dart`

**Modify login method to handle MFA:**
```dart
/// Login user - Returns MFARequiredResponse if MFA is enabled
Future<dynamic> login(String email, String password) async {
  state = const AuthLoading();

  final loginUseCase = ref.read(loginUseCaseProvider);
  final result = await loginUseCase(email: email, password: password);

  return result.when(
    success: (user) {
      // Success - MFA not enabled
      try {
        ref.invalidate(kycStatusControllerProvider);
      } catch (_) {}

      state = AuthSuccess('Login successful', user);
      return true;
    },
    failure: (failure) {
      // Check if failure is MFA required (HTTP 202)
      if (failure is ServerFailure && failure.statusCode == 202) {
        // Extract MFA required data from failure
        // Note: You may need to update ErrorMapper to preserve response data
        state = const AuthIdle(); // Don't show error
        return failure.data; // Return MFARequiredResponse data
      }
      
      state = AuthError(_failureToMessage(failure));
      return false;
    },
  );
}

/// Verify MFA token after login
Future<bool> verifyMFA(String userId, String token) async {
  state = const AuthLoading();

  final authRepository = ref.read(authRepositoryProvider);
  final result = await authRepository.verifyMFA(
    userId: userId,
    token: token,
  );

  return result.when(
    success: (tokens) {
      // Save tokens and load user profile
      final saveSession = ref.read(saveSessionUseCaseProvider);
      // ... save tokens logic ...
      
      state = const AuthSuccess('MFA verified successfully');
      return true;
    },
    failure: (failure) {
      state = AuthError(_failureToMessage(failure));
      return false;
    },
  );
}
```

#### 6. Create MFA Verification Screen

**New File:** `lib/features/auth/presentation/mfa_verify_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';
import '../../navigation/main_navigation_shell.dart';

/// Screen to verify MFA token during login
class MFAVerifyScreen extends ConsumerStatefulWidget {
  final String userId;
  final String email;

  const MFAVerifyScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  ConsumerState<MFAVerifyScreen> createState() => _MFAVerifyScreenState();
}

class _MFAVerifyScreenState extends ConsumerState<MFAVerifyScreen> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .verifyMFA(widget.userId, _tokenController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.alertHigh,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify MFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Icon
                Icon(
                  Icons.security,
                  size: 80,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Two-Factor Authentication',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter the 6-digit code from your authenticator app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Token Input
                TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: 'Authentication Code',
                    hintText: '000000',
                    prefixIcon: const Icon(Icons.pin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter verification code';
                    }
                    if (value.length != 6) {
                      return 'Code must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Verify Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Backup Code Link
                TextButton(
                  onPressed: () {
                    // TODO: Show dialog to enter backup code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use backup code feature coming soon'),
                      ),
                    );
                  },
                  child: const Text('Use backup code instead'),
                ),
                const SizedBox(height: 8),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Open your authenticator app (Google Authenticator, Authy, etc.) and enter the code shown.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 7. Update Login Screen

**File:** `lib/features/auth/presentation/login_screen.dart`

**Update `_handleLogin` method:**
```dart
Future<void> _handleLogin() async {
  if (_formKey.currentState?.validate() ?? false) {
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (mounted) {
      if (result is Map<String, dynamic>) {
        // MFA required - navigate to MFA verify screen
        final mfaRequired = result['mfa_required'] ?? false;
        if (mfaRequired) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MFAVerifyScreen(
                userId: result['user_id'],
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      }
      // If result is true, auth controller handles navigation
    }
  }
}
```

#### 8. Create MFA Setup Screen (Profile Feature)

**New File:** `lib/features/auth/presentation/mfa_setup_screen.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';

/// Screen to setup MFA for the first time
class MFASetupScreen extends ConsumerStatefulWidget {
  const MFASetupScreen({super.key});

  @override
  ConsumerState<MFASetupScreen> createState() => _MFASetupScreenState();
}

class _MFASetupScreenState extends ConsumerState<MFASetupScreen> {
  String? _secret;
  String? _qrCode; // base64 encoded PNG
  List<String>? _backupCodes;
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isSetupComplete = false;

  @override
  void initState() {
    super.initState();
    _initiateMFASetup();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _initiateMFASetup() async {
    setState(() => _isLoading = true);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.setupMFA();

    result.when(
      success: (setup) {
        setState(() {
          _secret = setup.secret;
          _qrCode = setup.qrCode;
          _isLoading = false;
        });
      },
      failure: (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to setup MFA: ${failure.message}'),
              backgroundColor: AppColors.alertHigh,
            ),
          );
        }
      },
    );
  }

  Future<void> _enableMFA() async {
    if (_tokenController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.enableMFA(_tokenController.text.trim());

    result.when(
      success: (response) {
        setState(() {
          _backupCodes = response.backupCodes;
          _isSetupComplete = true;
          _isLoading = false;
        });
      },
      failure: (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.alertHigh,
            ),
          );
        }
      },
    );
  }

  void _copyBackupCodes() {
    if (_backupCodes != null) {
      Clipboard.setData(ClipboardData(text: _backupCodes!.join('\n')));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup codes copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Setup MFA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isSetupComplete && _backupCodes != null) {
      return _buildBackupCodesView();
    }

    return _buildQRCodeView();
  }

  Widget _buildQRCodeView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Two-Factor Authentication')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1
              Text(
                'Step 1: Scan QR Code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Open your authenticator app and scan this QR code',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // QR Code
              if (_qrCode != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.memory(
                      base64Decode(_qrCode!),
                      width: 250,
                      height: 250,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Manual Entry
              if (_secret != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Or enter this code manually:',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _secret!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Step 2
              Text(
                'Step 2: Verify',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code from your app',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Token Input
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Enable Button
              ElevatedButton(
                onPressed: _isLoading ? null : _enableMFA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enable Two-Factor Authentication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupCodesView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Codes')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),

              Text(
                'MFA Enabled Successfully!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700]),
                    const SizedBox(height: 8),
                    Text(
                      'Save these backup codes in a safe place',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can use these codes to login if you lose access to your authenticator app',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Backup Codes
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: _backupCodes!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _backupCodes![index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Copy Button
              ElevatedButton.icon(
                onPressed: _copyBackupCodes,
                icon: const Icon(Icons.copy),
                label: const Text('Copy All Codes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Done Button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 9. Add MFA Controls to Profile Screen

**File:** `lib/features/auth/presentation/profile_screen.dart`

**Add MFA section:**
```dart
// In the profile settings list, add:

ListTile(
  leading: const Icon(Icons.security),
  title: const Text('Two-Factor Authentication'),
  subtitle: Text(mfaEnabled ? 'Enabled' : 'Disabled'),
  trailing: Switch(
    value: mfaEnabled,
    onChanged: (value) {
      if (value) {
        // Enable MFA
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MFASetupScreen()),
        ).then((enabled) {
          if (enabled == true) {
            // Refresh MFA status
            _loadMFAStatus();
          }
        });
      } else {
        // Disable MFA (show confirmation dialog)
        _showDisableMFADialog();
      }
    },
  ),
),
```

---

## ✅ Phase 5: Data Retention Policies - No Changes Required

**Backend Implementation:** Admin feature for automated data cleanup

**Mobile Impact:**
- ✅ No changes needed
- Backend automatically archives/deletes old data
- Transparent to mobile users
- No API changes

**User Impact:**
- Old reports may be archived after 5 years
- Old audit logs deleted after 2 years
- Read notifications deleted after 1 year
- Deleted accounts permanently removed after 30 days

---

## 📱 Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # For MFA (if not already included)
  qr_flutter: ^4.1.0  # For displaying QR codes (if needed for alternative flows)
  # Note: Base64 image display is already supported in Flutter
```

---

## 🧪 Testing Checklist

### MFA Testing

**Setup Flow:**
- [ ] Navigate to Profile → Security Settings
- [ ] Enable MFA toggle
- [ ] QR code displays correctly
- [ ] Scan QR code with Google Authenticator/Authy
- [ ] Enter verification code
- [ ] Backup codes displayed and copyable
- [ ] Save backup codes
- [ ] Complete setup successfully

**Login Flow with MFA:**
- [ ] Login with MFA-enabled account
- [ ] Verify `mfa_required: true` received
- [ ] Navigate to MFA verification screen
- [ ] Enter correct 6-digit code
- [ ] Successfully login to app
- [ ] Test with incorrect code (should fail)

**Disable MFA:**
- [ ] Navigate to Profile → Security Settings
- [ ] Disable MFA toggle
- [ ] Enter verification code to confirm
- [ ] MFA successfully disabled
- [ ] Login without MFA prompt

**Error Handling:**
- [ ] Test invalid verification codes
- [ ] Test expired/used backup codes
- [ ] Test network errors during MFA setup
- [ ] Test going back during MFA verification

---

## 📊 Expected API Changes

### Login Endpoint Changes

**Before (Phase 1-3):**
```json
POST /api/auth/login/
{
  "email": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": { ... }
}
```

**After MFA (Phase 4):**

**Case 1: MFA Not Enabled (same as before)**
```json
POST /api/auth/login/
{
  "email": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": { ... }
}
```

**Case 2: MFA Enabled (requires additional step)**
```json
POST /api/auth/login/
{
  "email": "user@example.com",
  "password": "password123"
}

Response 202 Accepted:
{
  "mfa_required": true,
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "message": "Please enter MFA token"
}

// Then verify MFA:
POST /api/auth/mfa/verify/
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "token": "123456"
}

Response 200:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": { ... }
}
```

---

## 🚀 Deployment Steps

### 1. Backend Preparation
- ✅ Backend Phases 1-5 already complete (147/147 tests passing)
- ✅ MFA endpoints available at `/api/auth/mfa/`
- Verify backend is running with MFA support

### 2. Mobile Development

**Phase A: Update Data Layer (1-2 days)**
1. Create `mfa_models.dart` with Freezed models
2. Run `flutter pub run build_runner build`
3. Update `api_constants.dart` with MFA endpoints
4. Update `auth_repository.dart` interface
5. Implement MFA methods in `auth_repository_impl.dart`

**Phase B: Update Business Logic (1 day)**
1. Update `auth_controller.dart` login method
2. Add `verifyMFA` method to controller
3. Handle 202 response in error mapper

**Phase C: Create UI (2-3 days)**
1. Create `mfa_verify_screen.dart`
2. Create `mfa_setup_screen.dart`
3. Update `login_screen.dart` to handle MFA flow
4. Add MFA section to `profile_screen.dart`

**Phase D: Testing (1-2 days)**
1. Unit tests for MFA repository methods
2. Widget tests for MFA screens
3. Integration tests for MFA flow
4. Manual testing with real authenticator apps

### 3. Integration Testing
- Test MFA setup flow end-to-end
- Test login with MFA-enabled account
- Test login without MFA (existing users)
- Test error scenarios
- Test backup codes

### 4. Rollout Strategy
**Option 1: Soft Launch (Recommended)**
- Deploy mobile update first (supports MFA but not required)
- Let existing users gradually enable MFA
- No breaking changes for users

**Option 2: Forced MFA (High Security)**
- Require all users to enable MFA after update
- Show MFA setup screen on first login after update
- May cause friction for some users

---

## 📋 Summary

### ✅ No Changes Required (4/5 Phases)
- **Phase 1:** Input Sanitization - Backend middleware
- **Phase 2:** Audit Logging - Server-side only
- **Phase 3:** Field Encryption - Transparent to mobile
- **Phase 5:** Data Retention - Admin feature only

### ⚠️ Changes Required (1/5 Phases)
- **Phase 4:** MFA Implementation - **HIGH PRIORITY**
  - 7 new Dart files
  - 4 modified files
  - ~1500 lines of code
  - Estimated effort: 5-7 days

### Development Estimate
- **Data Layer:** 1-2 days
- **Business Logic:** 1 day
- **UI Implementation:** 2-3 days
- **Testing:** 1-2 days
- **Total:** ~1 week

### User Impact
- More secure authentication with MFA
- Optional feature (users can enable/disable)
- Minimal friction for users without MFA
- One-time setup for users enabling MFA

---

**Next Steps:**
1. Review this document with the team
2. Create GitHub issues for MFA implementation
3. Prioritize MFA UI/UX design
4. Start implementing data layer changes
5. Test with backend MFA endpoints

**Questions or concerns? Create an issue or discuss with the team!** 🚀
