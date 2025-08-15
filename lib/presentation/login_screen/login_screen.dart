import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/app_logo.dart';
import './widgets/login_form.dart';
import './widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet;
    });
  }

  void _listenToConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final hasConnection = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;

      setState(() {
        _isConnected = hasConnection;
      });

      if (!hasConnection) {
        _showConnectionError();
      }
    });
  }

  void _showConnectionError() {
    Fluttertoast.showToast(
      msg: 'No internet connection. Please check your network settings.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
    );
  }

  void _clearErrors() {
    setState(() {
      _showEmailError = false;
      _showPasswordError = false;
      _emailErrorText = null;
      _passwordErrorText = null;
    });
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }

    // Handle network/connection errors
    String errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('host lookup failed') ||
        errorString.contains('no address associated with hostname')) {
      return 'Connection error. Please check your internet connection and try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _handleLogin() async {
    _clearErrors();

    // Check connectivity first
    if (!_isConnected) {
      _showConnectionError();
      return;
    }

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Validate inputs before API call
      if (email.isEmpty) {
        setState(() {
          _showEmailError = true;
          _emailErrorText = 'Please enter your email address.';
        });
        return;
      }

      if (password.isEmpty) {
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = 'Please enter your password.';
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = 'Password must be at least 6 characters long.';
        });
        return;
      }

      // FIXED: Enhanced authentication call with better error handling
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      // Check if sign in was successful
      if (response.user != null) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        Fluttertoast.showToast(
          msg: "Welcome back to Tam Tam!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          textColor: AppTheme.lightTheme.colorScheme.onPrimary,
        );

        // Navigate to main video feed
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main-video-feed');
        }
      } else {
        // Handle case where response.user is null
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = 'Login failed. Please check your credentials.';
        });

        Fluttertoast.showToast(
          msg: 'Login failed. Please check your credentials.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: AppTheme.lightTheme.colorScheme.onError,
        );
      }
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);

      // Set appropriate error state based on error type
      if (errorMessage.toLowerCase().contains('email') &&
          !errorMessage.toLowerCase().contains('password')) {
        setState(() {
          _showEmailError = true;
          _emailErrorText = errorMessage;
        });
      } else if (errorMessage.toLowerCase().contains('password') ||
          errorMessage.toLowerCase().contains('credentials')) {
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = errorMessage;
        });
      } else if (errorMessage.toLowerCase().contains('connection') ||
          errorMessage.toLowerCase().contains('network')) {
        // Connection errors - show for both fields
        setState(() {
          _showEmailError = false;
          _showPasswordError = true;
          _passwordErrorText = errorMessage;
        });
      } else {
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = errorMessage;
        });
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleForgotPassword() async {
    // Check connectivity first
    if (!_isConnected) {
      _showConnectionError();
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email address first",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
      return;
    }

    try {
      await _authService.resetPassword(email: _emailController.text.trim());

      Fluttertoast.showToast(
        msg: "Password reset link sent to your email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    // Check connectivity first
    if (!_isConnected) {
      _showConnectionError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      switch (provider.toLowerCase()) {
        case 'google':
          success = await _authService.signInWithGoogle();
          break;
        case 'apple':
          success = await _authService.signInWithApple();
          break;
        default:
          Fluttertoast.showToast(
            msg: "$provider login coming soon!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          return;
      }

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/main-video-feed');
      } else if (!success) {
        Fluttertoast.showToast(
          msg:
              "Social login failed. Please check your connection and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: AppTheme.lightTheme.colorScheme.onError,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Social login failed. Please check your connection and try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED: Add connection status indicator
            if (!_isConnected)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                color: AppTheme.lightTheme.colorScheme.error,
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: AppTheme.lightTheme.colorScheme.onError,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'No internet connection',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onError,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        (_isConnected ? 0 : 40), // Account for connection bar
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),

                      // App Logo Section
                      const AppLogo(),

                      SizedBox(height: 6.h),

                      // Welcome Text
                      Text(
                        'Welcome Back!',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        'Sign in to continue your creative journey',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 4.h),

                      // Login Form
                      LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        formKey: _formKey,
                        showEmailError: _showEmailError,
                        showPasswordError: _showPasswordError,
                        emailErrorText: _emailErrorText,
                        passwordErrorText: _passwordErrorText,
                        onForgotPassword: _handleForgotPassword,
                      ),

                      SizedBox(height: 3.h),

                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isConnected)
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            foregroundColor:
                                AppTheme.lightTheme.colorScheme.onPrimary,
                            elevation: 2,
                            shadowColor: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'Or continue with',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Social Login Buttons
                      SocialLoginButton(
                        iconName: 'g_translate',
                        label: 'Continue with Google',
                        onPressed: _isConnected
                            ? () => _handleSocialLogin('Google')
                            : () {},
                      ),

                      SizedBox(height: 4.h),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New user? ',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToSignUp,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign Up',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}