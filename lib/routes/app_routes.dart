import 'package:flutter/material.dart';
import '../presentation/creator_analytics_dashboard/creator_analytics_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/send_money_screen/send_money_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../widgets/persistent_navigation_wrapper.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding-flow';
  static const String creatorAnalyticsDashboard =
      '/creator-analytics-dashboard';
  static const String mainVideoFeed = '/main-video-feed';
  static const String liveStreamingInterface = '/live-streaming-interface';
  static const String userProfile = '/user-profile-screen';
  static const String login = '/login-screen';
  static const String sendMoney = '/send-money-screen';
  static const String videoCreationStudio = '/video-creation-studio';
  static const String registration = '/registration-screen';
  static const String persistentNav = '/persistent-nav';
  static const String cryptoWalletDashboard = '/crypto-wallet-dashboard';

  static Map<String, WidgetBuilder> routes = {
    // Start with splash screen for proper initialization
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingFlow(),
    creatorAnalyticsDashboard: (context) => const CreatorAnalyticsDashboard(),
    login: (context) => const LoginScreen(),
    sendMoney: (context) => const SendMoneyScreen(),
    registration: (context) => const RegistrationScreen(),
    persistentNav: (context) => const PersistentNavigationWrapper(),

    // These routes now use the persistent navigation wrapper
    // The onGenerateRoute in main.dart handles routing to appropriate tabs
    mainVideoFeed: (context) =>
        const PersistentNavigationWrapper(initialIndex: 0),
    liveStreamingInterface: (context) =>
        const PersistentNavigationWrapper(initialIndex: 1),
    videoCreationStudio: (context) =>
        const PersistentNavigationWrapper(initialIndex: 2),
    cryptoWalletDashboard: (context) =>
        const PersistentNavigationWrapper(initialIndex: 3),
    userProfile: (context) =>
        const PersistentNavigationWrapper(initialIndex: 4),
    // TODO: Add your other routes here
  };
}
