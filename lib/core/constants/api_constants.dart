import 'dart:io';

class ApiConstants {
  // ─── DEPLOYMENT CONFIG ─────────────────────────────────────────────────────
  //
  // LOCAL DEV  → use the emulator aliases below (already set up)
  // REAL DEVICE (same WiFi as PC) → set _devServerIp to your PC's LAN IP
  //   e.g. '192.168.1.10' — run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  // PRODUCTION → set _prodUrl to your hosted domain (HTTPS recommended)
  //
  static const bool _isProduction = false; // ← flip to true for prod build
  static const String _prodUrl = 'https://your-production-domain.com'; // ← set this
  static const String _devServerIp = '127.0.0.1'; // adb reverse tunnel — routes through USB to PC port 8000
  // ───────────────────────────────────────────────────────────────────────────

  static String get baseUrl {
    if (_isProduction) return '$_prodUrl/api';
    if (_devServerIp.isNotEmpty) return 'http://$_devServerIp:8000/api';
    // Emulator fallbacks
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  // Media base URL (without /api suffix)
  static String get mediaBaseUrl {
    if (_isProduction) return _prodUrl;
    if (_devServerIp.isNotEmpty) return 'http://$_devServerIp:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  /// Build full URL for an image path
  /// Handles both relative (/media/...) and absolute URLs
  static String getImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '$mediaBaseUrl$url';
  }

  // Auth Endpoints (trailing slashes required for Django)
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String refresh = '/auth/refresh/';
  static const String logout = '/auth/logout/';
  static const String logoutAll = '/auth/logout-all/';
  static const String forgotPassword = '/auth/forgot-password/';
  static const String verifyResetOtp = '/auth/verify-otp/';
  static const String resetPassword = '/auth/reset-password/';
  static const String profile = '/auth/profile/';
  static const String profileUpdate = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';

  // Reports Endpoints
  static const String reports = '/reports/';
  static const String myReports = '/reports/my-reports/';
  static const String reportStats = '/reports/stats/';
  static const String reportFormOptions = '/reports/form-options/';
  static String reportById(String id) => '/reports/$id/';
  static String reportVerify(String id) => '/reports/$id/verify/';

  // Images Endpoints
  static const String images = '/images/';
  static const String imageUpload = '/images/upload/';
  static const String imageBulkUpload = '/images/bulk-upload/';
  static String imageById(String id) => '/images/$id/';

  // Notifications Endpoints
  static const String notifications = '/notifications/';
  static const String notificationPreferences = '/notifications/preferences/';
  static const String notificationMarkAllRead = '/notifications/mark-all-read/';
  static const String notificationPushToken = '/notifications/push-token/';
  static String notificationById(String id) => '/notifications/$id/';

  // KYC Endpoints
  static const String kycIdTypes = '/auth/kyc/id-types/';
  static const String kycSubmit = '/auth/kyc/submit/';
  static const String kycStatus = '/auth/kyc/status/';
  static const String kycResubmit = '/auth/kyc/resubmit/';
  static const String kycFormOptions = '/auth/kyc/form-options/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
