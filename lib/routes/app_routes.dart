import 'package:flutter/material.dart';
import '../presentation/creator_analytics_dashboard/creator_analytics_dashboard.dart';
import '../presentation/main_video_feed/main_video_feed.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/live_streaming_interface/live_streaming_interface.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/send_money_screen/send_money_screen.dart';
import '../presentation/video_creation_studio/video_creation_studio.dart';
import '../presentation/crypto_wallet_dashboard/crypto_wallet_dashboard.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String creatorAnalyticsDashboard =
      '/creator-analytics-dashboard';
  static const String mainVideoFeed = '/main-video-feed';
  static const String splash = '/splash-screen';
  static const String liveStreamingInterface = '/live-streaming-interface';
  static const String userProfile = '/user-profile-screen';
  static const String login = '/login-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String sendMoney = '/send-money-screen';
  static const String videoCreationStudio = '/video-creation-studio';
  static const String cryptoWalletDashboard = '/crypto-wallet-dashboard';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    creatorAnalyticsDashboard: (context) => const CreatorAnalyticsDashboard(),
    mainVideoFeed: (context) => const MainVideoFeed(),
    splash: (context) => const SplashScreen(),
    liveStreamingInterface: (context) => const LiveStreamingInterface(),
    userProfile: (context) => const UserProfileScreen(),
    login: (context) => const LoginScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    sendMoney: (context) => const SendMoneyScreen(),
    videoCreationStudio: (context) => const VideoCreationStudio(),
    cryptoWalletDashboard: (context) => const CryptoWalletDashboard(),
    registration: (context) => const RegistrationScreen(),
    // TODO: Add your other routes here
  };
}
