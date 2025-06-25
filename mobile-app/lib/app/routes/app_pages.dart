// lib/app/routes/app_pages.dart
import 'package:flutter/material.dart';
import '../../presentation/auth/login/login_view.dart';
import '../../presentation/profile/setup/setup_profile_view.dart';
import '../../presentation/auth/reset_password/reset_password_view.dart';
import '../../presentation/auth/register/register_view.dart';
import '../../presentation/auth/login_otp/login_otp_view.dart';
import '../../presentation/auth/login_otp/login_otp_verify_view.dart';
import '../../presentation/common/terms_of_service_view.dart';
import '../../presentation/common/privacy_policy_view.dart';
import '../../presentation/discovery/discovery_view.dart';
import '../../presentation/main_navigator/main_navigator_view.dart';
import '../../presentation/splash/splash_view.dart';
import '../../presentation/welcome/welcome_view.dart';
import '../../presentation/profile/setup/widgets/profile_setup_complete_screen.dart';
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
        final sessionToken = args?['sessionToken'] as String?;
        return MaterialPageRoute(
          builder: (_) => SetupProfileView(sessionToken: sessionToken),
        );
      case AppRoutes.profileSetupComplete:
        return MaterialPageRoute(builder: (_) => const ProfileSetupCompleteScreen());
      case AppRoutes.mainNavigator:
        return MaterialPageRoute(builder: (_) => const MainNavigatorView());
      case AppRoutes.discovery:
        return MaterialPageRoute(builder: (_) => const DiscoveryView());
      default:
        return MaterialPageRoute(builder: (_) => const SplashView());
    }
  }
}