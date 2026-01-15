class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/profile';
  static const String profileUpdate = '/auth/profile/update';
  static const String changePassword = '/auth/change-password';

  // Reports Endpoints
  static const String reports = '/reports/';
  static const String myReports = '/reports/my-reports/';
  static const String reportStats = '/reports/stats/';
  static String reportById(String id) => '/reports/$id/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
