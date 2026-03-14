class ApiConstants {
  // ─── DEPLOYMENT CONFIG ─────────────────────────────────────────────────────
  //
  // MODE A — USB cable + adb reverse (no firewall issues):
  //   1. Connect phone via USB
  //   2. Run: adb reverse tcp:8000 tcp:8000
  //   3. Django: python manage.py runserver   (127.0.0.1:8000 is fine)
  //   4. Set _devServerIp = ''  →  app uses http://localhost:8000
  //
  // MODE B — WiFi / mobile hotspot (USB not required):
  //   1. Django MUST bind to all interfaces: python manage.py runserver 0.0.0.0:8000
  //   2. Allow port 8000 through Windows Firewall (if prompted, click "Allow")
  //   3. Set _devServerIp = '<your PC WiFi IP>'  (run ipconfig → Wi-Fi IPv4)
  //      Current PC Wi-Fi IP: 192.168.1.23
  //
  // PRODUCTION → flip _isProduction to true and fill _prodUrl
  //
  static const bool _isProduction = false;
  static const String _prodUrl = 'https://your-production-domain.com';

  // MODE A (USB+adb): leave empty. MODE B (WiFi): set to PC's WiFi IP.
  static const String _devServerIp = '192.168.1.37';
  // ───────────────────────────────────────────────────────────────────────────

  static String get baseUrl {
    if (_isProduction) return '$_prodUrl/api';
    if (_devServerIp.isNotEmpty) return 'http://$_devServerIp:8000/api';
    // MODE A: adb reverse tunnels device localhost → PC localhost:8000
    return 'http://10.0.2.2:8000/api';
  }

  // Media base URL (without /api suffix)
  static String get mediaBaseUrl {
    if (_isProduction) return _prodUrl;
    if (_devServerIp.isNotEmpty) return 'http://$_devServerIp:8000';
    return 'http://10.0.2.2:8000';
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
  static const String barangays = '/auth/barangays/';

  // Reports Endpoints
  static const String reports = '/reports/';
  static const String myReports = '/reports/my-reports/';
  static const String reportStats = '/reports/stats/';
  static const String reportFormOptions = '/reports/form-options/';
  static String reportById(String id) => '/reports/$id/';
  static String reportVerify(String id) => '/reports/$id/verify/';
  static String reportCitizenClose(String id) => '/reports/$id/citizen-close/';
  static String reportBarangayResolve(String id) =>
      '/reports/$id/barangay-resolve/';

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
