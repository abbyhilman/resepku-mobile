class AppConstants {
  AppConstants._();

  static const String appName = 'ResepKu';
  static const String baseUrl = 'https://resepku-api.vercel.app/api/v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
