class ApiConstants {
  // Pass complete URLs at build/run time. The default targets an Android
  // emulator; physical devices use a LAN URL or 127.0.0.1 with adb reverse.
  static const String baseUrl = String.fromEnvironment(
    'BAYANTRACK_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  static const String mediaBaseUrl = String.fromEnvironment(
    'BAYANTRACK_MEDIA_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const String health = '/health/';

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
  static const String profileAvatar = '/auth/profile/avatar/';
  static const String changePassword = '/auth/change-password/';
  static const String municipalities = '/auth/municipalities/';
  static const String barangays = '/auth/barangays/';
  static const String nearbyLandmarks = '/auth/nearby-landmarks/';

  // Reports Endpoints
  static const String reports = '/reports/';
  static const String nearbyReports = '/reports/nearby/';
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
  static String imageById(String id) => '/images/$id/';

  // Notifications Endpoints
  static const String notifications = '/notifications/';
  static const String notificationPreferences = '/notifications/preferences/';
  static const String notificationMarkAllRead =
      '/notifications/actions/mark-all-read/';
  static const String notificationPushToken = '/notifications/push-token/';
  static String notificationById(String id) => '/notifications/$id/';

  // Preferred identity verification endpoints
  static const String verificationIdTypes = '/auth/verification/id-types/';
  static const String verificationSubmit = '/auth/verification/submit/';
  static const String verificationStatus = '/auth/verification/status/';
  static const String verificationWithdraw = '/auth/verification/withdraw/';
  static const String verificationResubmit = '/auth/verification/resubmit/';
  static const String verificationFormOptions =
      '/auth/verification/form-options/';

  // Legacy KYC route aliases
  static const String kycIdTypes = '/auth/kyc/id-types/';
  static const String kycSubmit = '/auth/kyc/submit/';
  static const String kycStatus = '/auth/kyc/status/';
  static const String kycWithdraw = '/auth/kyc/withdraw/';
  static const String kycResubmit = '/auth/kyc/resubmit/';
  static const String kycFormOptions = '/auth/kyc/form-options/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
