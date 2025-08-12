import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './core/app_export.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
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
          ),
        );
      },
    );
  }
}
