// lib/app/routes/app_routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String loginWithEmailOtp = '/login-with-email-otp';
  static const String loginEmailOtpVerify = '/login-email-otp-verify';
  static const String forgotPasswordOtpVerify = '/forgot-password-otp-verify';
  static const String setupProfile = '/setup-profile';
  static const String mainNavigator = '/main';
  static const String discovery = '/discovery';
}

enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://10.0.2.2:8080/api';
      case Environment.staging:
        return 'https://staging.api.amoura.com';
      case Environment.prod:
        return 'https://api.amoura.com';
    }
  }
}