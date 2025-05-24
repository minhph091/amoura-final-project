// lib/app/routes/app_pages.dart
import 'package:flutter/material.dart';
import '../../presentation/auth/login/login_view.dart';
import '../../presentation/auth/setup_profile/setup_profile_view.dart';
import '../../presentation/auth/reset_password/reset_password_view.dart';
import '../../presentation/auth/register/register_view.dart';
import '../../presentation/auth/login_otp/login_otp_view.dart';
import '../../presentation/auth/login_otp/login_otp_verify_view.dart'; // Chỉ import từ đây
import '../../presentation/common/terms_of_service_view.dart';
import '../../presentation/common/privacy_policy_view.dart';
import '../../presentation/splash/splash_view.dart';
import '../../presentation/welcome/welcome_view.dart';
import '../../presentation/main_navigator/main_navigator_view.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeView());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case AppRoutes.termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceView());
      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyView());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case AppRoutes.forgotPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordView(email: email),
        );
      case AppRoutes.loginWithEmailOtp:
        return MaterialPageRoute(builder: (_) => const LoginOtpView());
      case AppRoutes.loginEmailOtpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] ?? '';
        return MaterialPageRoute(
          builder: (_) => LoginOtpVerifyView(email: email),
        );
      case AppRoutes.forgotPasswordOtpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordView(email: email),
        );
      case AppRoutes.setupProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const SetupProfileView(),
          settings: RouteSettings(arguments: args),
        );
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainNavigatorView());
      default:
        return MaterialPageRoute(builder: (_) => const SplashView());
    }
  }
}

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
  static const String home = '/home';
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