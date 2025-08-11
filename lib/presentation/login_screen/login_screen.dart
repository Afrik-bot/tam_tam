import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
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

  bool _isLoading = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'user@tamtam.com': 'password123',
    'creator@tamtam.com': 'creator456',
    'admin@tamtam.com': 'admin789',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _showEmailError = false;
      _showPasswordError = false;
      _emailErrorText = null;
      _passwordErrorText = null;
    });
  }

  Future<void> _handleLogin() async {
    _clearErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check mock credentials
    if (_mockCredentials.containsKey(email) &&
        _mockCredentials[email] == password) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Login successful! Welcome to Tam Tam",
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
      // Handle different error scenarios
      if (!_mockCredentials.containsKey(email)) {
        setState(() {
          _showEmailError = true;
          _emailErrorText = 'Account not found. Please check your email.';
        });
      } else {
        setState(() {
          _showPasswordError = true;
          _passwordErrorText = 'Incorrect password. Please try again.';
        });
      }

      Fluttertoast.showToast(
        msg: "Invalid credentials. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleForgotPassword() {
    Fluttertoast.showToast(
      msg: "Password reset link sent to your email",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleSocialLogin(String provider) {
    Fluttertoast.showToast(
      msg: "Redirecting to $provider login...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate social login success
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main-video-feed');
      }
    });
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
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
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  'Sign in to continue your creative journey',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
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
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
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
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                  onPressed: () => _handleSocialLogin('Google'),
                ),

                SocialLoginButton(
                  iconName: 'apple',
                  label: 'Continue with Apple',
                  onPressed: () => _handleSocialLogin('Apple'),
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),

                SocialLoginButton(
                  iconName: 'facebook',
                  label: 'Continue with Facebook',
                  onPressed: () => _handleSocialLogin('Facebook'),
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                ),

                SizedBox(height: 4.h),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
    );
  }
}
