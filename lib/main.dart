import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './core/app_export.dart';
import './services/supabase_service.dart';
import './widgets/persistent_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  // FIXED: Single Supabase initialization with proper error handling
  try {
    await SupabaseService.instance.initialize();
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // Continue with app startup even if Supabase fails to initialize
    // This prevents the app from crashing during development
  }

  runApp(const TamTamApp());
}

class TamTamApp extends StatelessWidget {
  const TamTamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            title: 'Tam Tam',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routes: AppRoutes.routes,
            // Start with splash screen to handle proper initialization
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              // Handle navigation with persistent navigation
              switch (settings.name) {
                case AppRoutes.mainVideoFeed:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const PersistentNavigationWrapper(initialIndex: 0),
                    settings: settings,
                  );
                case AppRoutes.liveStreamingInterface:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const PersistentNavigationWrapper(initialIndex: 1),
                    settings: settings,
                  );
                case AppRoutes.videoCreationStudio:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const PersistentNavigationWrapper(initialIndex: 2),
                    settings: settings,
                  );
                case AppRoutes.cryptoWalletDashboard:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const PersistentNavigationWrapper(initialIndex: 3),
                    settings: settings,
                  );
                case AppRoutes.userProfile:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const PersistentNavigationWrapper(initialIndex: 4),
                    settings: settings,
                  );
                default:
                  return null;
              }
            },
          ),
        );
      },
    );
  }
}