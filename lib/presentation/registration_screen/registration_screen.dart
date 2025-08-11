import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/registration_form.dart';
import './widgets/social_signup_buttons.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  double _passwordStrength = 0.0;
  String _selectedCountryCode = '+1';
  DateTime? _selectedDate;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  late AnimationController _formAnimationController;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() {
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError = null;
        _isUsernameAvailable = true;
      });
      return;
    }

    // Basic validation
    if (value.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError = 'Username must be at least 3 characters';
        _isUsernameAvailable = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      // Check username availability with real Supabase
      final isAvailable = await AuthService.checkUsernameAvailability(value);

      if (mounted && _usernameController.text == value) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = isAvailable;
          _usernameError = isAvailable ? null : 'Username is already taken';
        });
      }
    } catch (e) {
      if (mounted && _usernameController.text == value) {
        setState(() {
          _isCheckingUsername = false;
          _usernameError = 'Error checking username availability';
          _isUsernameAvailable = false;
        });
      }
    }
  }

  void _onEmailChanged(String value) async {
    setState(() {
      _emailError = null;
    });

    if (value.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      try {
        // Check email availability with real Supabase
        final isAvailable = await AuthService.checkEmailAvailability(value);
        if (mounted && _emailController.text == value) {
          setState(() {
            _emailError = isAvailable ? null : 'Email is already registered';
          });
        }
      } catch (e) {
        // Silently fail - don't show error for email checking
      }
    }
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _phoneError = null;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = null;
      _passwordStrength = _calculatePasswordStrength(value);
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  void _onCountryCodeChanged(String code) {
    setState(() {
      _selectedCountryCode = code;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onTermsChanged(bool accepted) {
    setState(() {
      _isTermsAccepted = accepted;
    });
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() == true &&
        _isUsernameAvailable &&
        !_isCheckingUsername &&
        _selectedDate != null &&
        _isTermsAccepted &&
        _passwordStrength >= 0.3 &&
        _emailError == null;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your birth date'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      } else if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please accept the Terms & Privacy Policy'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      } else if (_passwordStrength < 0.3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please create a stronger password'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Supabase
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        fullName: _usernameController.text
            .trim(), // Using username as full name for now
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          // Registration successful
          _showSuccessDialog();
        } else {
          // Registration failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration failed. Please try again.'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Registration failed. Please try again.';

        // Handle specific Supabase errors
        if (e.toString().contains('User already registered')) {
          errorMessage = 'Email is already registered. Please try logging in.';
        } else if (e
            .toString()
            .contains('Password should be at least 6 characters')) {
          errorMessage = 'Password should be at least 6 characters long.';
        } else if (e.toString().contains('Unable to validate email')) {
          errorMessage = 'Please enter a valid email address.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 2.h),
            Text(
              'Welcome to Tam Tam!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your account has been created successfully',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/main-video-feed');
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSocialSignup(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      switch (provider) {
        case 'Google':
          success = await AuthService.signInWithGoogle();
          break;
        case 'Apple':
          success = await AuthService.signInWithApple();
          break;
        case 'Facebook':
          // Facebook OAuth not implemented in AuthService yet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Facebook signup coming soon'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
          break;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success && provider != 'Facebook') {
          Navigator.pushReplacementNamed(context, '/main-video-feed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider signup failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4.h),
                  _buildLogo(),
                  SizedBox(height: 4.h),
                  _buildFormSection(),
                  SizedBox(height: 3.h),
                  _buildCreateAccountButton(),
                  SizedBox(height: 3.h),
                  _buildSocialSignupSection(),
                  SizedBox(height: 3.h),
                  _buildLoginLink(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Column(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'TT',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Tam Tam',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Create, Connect, Earn',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: RegistrationForm(
          formKey: _formKey,
          usernameController: _usernameController,
          emailController: _emailController,
          phoneController: _phoneController,
          passwordController: _passwordController,
          onUsernameChanged: _onUsernameChanged,
          onEmailChanged: _onEmailChanged,
          onPhoneChanged: _onPhoneChanged,
          onPasswordChanged: _onPasswordChanged,
          isUsernameAvailable: _isUsernameAvailable,
          isCheckingUsername: _isCheckingUsername,
          usernameError: _usernameError,
          emailError: _emailError,
          phoneError: _phoneError,
          passwordError: _passwordError,
          passwordStrength: _passwordStrength,
          selectedCountryCode: _selectedCountryCode,
          onCountryCodeChanged: _onCountryCodeChanged,
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          isTermsAccepted: _isTermsAccepted,
          onTermsChanged: _onTermsChanged,
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isFormValid() && !_isLoading ? _handleRegistration : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid()
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          elevation: _isFormValid() ? 4 : 0,
          shadowColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialSignupSection() {
    return SocialSignupButtons(
      onGoogleSignup: () => _handleSocialSignup('Google'),
      onAppleSignup: () => _handleSocialSignup('Apple'),
      onFacebookSignup: () => _handleSocialSignup('Facebook'),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login-screen');
          },
          child: Text(
            'Login',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Creating your account...',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
