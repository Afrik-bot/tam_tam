import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Alignment> _gradientAnimation;

  bool _isInitializing = true;
  double _loadingProgress = 0.0;
  String _loadingText = "Initializing...";

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background gradient animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Background gradient animation
    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoAnimationController.forward();
    _backgroundAnimationController.repeat(reverse: true);
  }

  Future<void> _initializeApp() async {
    try {
      // Hide system status bar for immersive experience
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

      // Simulate app initialization steps
      await _performInitializationSteps();

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on user state
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors
      _handleInitializationError();
    }
  }

  Future<void> _performInitializationSteps() async {
    final steps = [
      {"text": "Connecting to Supabase...", "duration": 400},
      {"text": "Checking authentication...", "duration": 300},
      {"text": "Loading user preferences...", "duration": 300},
      {"text": "Fetching config data...", "duration": 500},
      {"text": "Preparing video content...", "duration": 600},
      {"text": "Ready to launch!", "duration": 200},
    ];

    for (int i = 0; i < steps.length; i++) {
      if (mounted) {
        setState(() {
          _loadingText = steps[i]["text"] as String;
          _loadingProgress = (i + 1) / steps.length;
        });
      }

      // Ensure Supabase is initialized during the first step
      if (i == 0 && !SupabaseService.instance.isInitialized) {
        try {
          await SupabaseService.instance.initialize();
        } catch (e) {
          // Continue even if Supabase fails - for development mode
          print('Supabase initialization failed during splash: $e');
        }
      }

      await Future.delayed(Duration(milliseconds: steps[i]["duration"] as int));
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Check authentication status and first time user
    bool isAuthenticated = false;
    try {
      isAuthenticated = AuthService.instance.isAuthenticated;
    } catch (e) {
      // Default to false if there's an error
      isAuthenticated = false;
    }

    final isFirstTime = await _checkFirstTimeUser();

    // Restore system UI before navigation
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      if (isFirstTime) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainVideoFeed);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  Future<bool> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('first_time_user') ?? true;

      if (isFirstTime) {
        await prefs.setBool('first_time_user', false);
        return true;
      }
      return false;
    } catch (e) {
      // If there's an error, assume first time user
      return true;
    }
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _loadingText = "Connection error - continuing in offline mode";
      });

      // Show retry option after 2 seconds, or continue to main app
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Navigate to login screen even with errors
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Connection Error',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Unable to initialize the app. Please check your internet connection and try again.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isInitializing = true;
                  _loadingProgress = 0.0;
                  _loadingText = "Retrying...";
                });
                _initializeApp();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('Continue Offline'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    // Restore system UI when leaving splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundAnimationController,
          _logoAnimationController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientAnimation.value,
                end: _gradientAnimation.value == Alignment.topLeft
                    ? Alignment.bottomRight
                    : Alignment.topLeft,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.secondary,
                  AppTheme.lightTheme.colorScheme.tertiary,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content to center
                  const Spacer(flex: 2),

                  // Logo section
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: _buildLogo(),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Loading section
                  if (_isInitializing) ...[
                    _buildLoadingIndicator(),
                    SizedBox(height: 3.h),
                    _buildLoadingText(),
                  ] else ...[
                    Icon(
                      Icons.wifi_off_outlined,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _loadingText,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Spacer to balance layout
                  const Spacer(flex: 3),

                  // Bottom branding
                  _buildBottomBranding(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 35.w,
      height: 35.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TAM',
              style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24.sp,
                letterSpacing: 2,
              ),
            ),
            Text(
              'TAM',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 60.w,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60.w * _loadingProgress,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomBranding() {
    return Column(
      children: [
        Text(
          'Create • Earn • Connect',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12.sp,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'v1.0.0 - Powered by Supabase',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
