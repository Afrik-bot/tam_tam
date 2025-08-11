import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
      {"text": "Checking authentication...", "duration": 400},
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
      await Future.delayed(Duration(milliseconds: steps[i]["duration"] as int));
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Simulate authentication check
    final isAuthenticated = await _checkAuthenticationStatus();
    final isFirstTime = await _checkFirstTimeUser();

    // Restore system UI before navigation
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      if (isFirstTime) {
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      } else if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/main-video-feed');
      } else {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate authentication check
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock logic - in real app, check stored tokens/credentials
    return false; // Return false to show login flow
  }

  Future<bool> _checkFirstTimeUser() async {
    // Simulate first-time user check
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock logic - in real app, check shared preferences
    return true; // Return true to show onboarding
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _isInitializing = false;
        _loadingText = "Something went wrong";
      });

      // Show retry option after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _showRetryDialog();
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
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _loadingText,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
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
          'v1.0.0',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
