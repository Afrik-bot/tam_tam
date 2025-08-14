import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
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

  List<String> _usernameSuggestions = [];
  bool _showSuggestions = false;

  bool _isUsernameAvailable = false;
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

  // Add connection status tracking
  bool _isSupabaseConnected = false;
  String? _connectionError;

  // Debouncing
  Timer? _usernameDebounceTimer;
  Timer? _emailDebounceTimer;

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
    _checkSupabaseConnection();
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      final isConnected = await SupabaseService.instance.testConnection();
      if (mounted) {
        setState(() {
          _isSupabaseConnected = isConnected;
          _connectionError = isConnected ? null : 'Database connection failed';
        });
      }

      if (isConnected) {
        _showSuccessSnackBar('Connected to Supabase successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSupabaseConnected = false;
          _connectionError = 'Connection error: ${e.toString()}';
        });
      }
    }
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
    _usernameDebounceTimer?.cancel();
    _emailDebounceTimer?.cancel();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    // Cancel previous timer
    _usernameDebounceTimer?.cancel();

    if (value.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError = null;
        _isUsernameAvailable = false;
        _showSuggestions = false;
        _usernameSuggestions = [];
      });
      return;
    }

    // Basic validation first
    if (value.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError = 'Username must be at least 3 characters';
        _isUsernameAvailable = false;
        _showSuggestions = false;
        _usernameSuggestions = [];
      });
      return;
    }

    // Check for invalid characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      setState(() {
        _isCheckingUsername = false;
        _usernameError =
            'Username can only contain letters, numbers, and underscores';
        _isUsernameAvailable = false;
        _showSuggestions = false;
        _usernameSuggestions = [];
      });
      return;
    }

    // Show checking state
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
      _showSuggestions = false;
      _usernameSuggestions = [];
    });

    // Debounce the API call
    _usernameDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkUsernameAvailability(value);
    });
  }

  Future<void> _checkUsernameAvailability(String value) async {
    if (!mounted || _usernameController.text != value) return;

    try {
      final isAvailable = await AuthService.checkUsernameAvailability(value);

      if (mounted && _usernameController.text == value) {
        if (isAvailable) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = true;
            _usernameError = null;
            _showSuggestions = false;
            _usernameSuggestions = [];
          });
        } else {
          // Get suggestions for alternative usernames
          final suggestions = await AuthService.getUsernameSuggestions(value);

          if (mounted && _usernameController.text == value) {
            setState(() {
              _isCheckingUsername = false;
              _isUsernameAvailable = false;
              _usernameError = 'Username is already taken';
              _showSuggestions = suggestions.isNotEmpty;
              _usernameSuggestions = suggestions;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && _usernameController.text == value) {
        setState(() {
          _isCheckingUsername = false;
          _usernameError = 'Unable to verify username availability';
          _isUsernameAvailable = false;
          _showSuggestions = false;
          _usernameSuggestions = [];
        });
      }
    }
  }

  void _onSuggestionTapped(String suggestion) {
    _usernameController.text = suggestion;
    setState(() {
      _showSuggestions = false;
      _usernameSuggestions = [];
      _isUsernameAvailable = true; // Suggestions are pre-validated
      _usernameError = null;
      _isCheckingUsername = false;
    });
  }

  void _onEmailChanged(String value) {
    // Cancel previous timer
    _emailDebounceTimer?.cancel();

    setState(() {
      _emailError = null;
    });

    if (value.isEmpty) return;

    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    // Debounce the availability check
    _emailDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _checkEmailAvailability(value);
    });
  }

  Future<void> _checkEmailAvailability(String value) async {
    if (!mounted || _emailController.text != value) return;

    try {
      final isAvailable = await AuthService.checkEmailAvailability(value);
      if (mounted && _emailController.text == value) {
        setState(() {
          _emailError = isAvailable ? null : 'Email is already registered';
        });
      }
    } catch (e) {
      // Don't show error for email checking failures
      // The actual signup will catch duplicate emails
    }
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _phoneError = null;
    });

    // Basic phone validation
    if (value.isNotEmpty && !RegExp(r'^\d{10,15}$').hasMatch(value)) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
    }
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = null;
      _passwordStrength = _calculatePasswordStrength(value);
    });

    // Password validation
    if (value.isNotEmpty && value.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
    }
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
    final formValid = _formKey.currentState?.validate() == true;
    final usernameValid = _usernameController.text.trim().isNotEmpty &&
        _isUsernameAvailable &&
        !_isCheckingUsername &&
        _usernameError == null;
    final emailValid =
        _emailController.text.trim().isNotEmpty && _emailError == null;
    final passwordValid = _passwordController.text.isNotEmpty &&
        _passwordStrength >= 0.3 &&
        _passwordError == null;
    final dateValid = _selectedDate != null;
    final termsValid = _isTermsAccepted;

    return formValid &&
        usernameValid &&
        emailValid &&
        passwordValid &&
        dateValid &&
        termsValid;
  }

  Future<void> _handleRegistration() async {
    // Check Supabase connection first
    if (!_isSupabaseConnected) {
      _showErrorSnackBar(
          'Database connection is required for registration. Please check your connection.');
      await _checkSupabaseConnection();
      return;
    }

    // Final validation before submission
    if (!_isFormValid()) {
      _showValidationErrors();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        fullName: _usernameController.text.trim(),
        phoneNumber: _phoneController.text.isNotEmpty
            ? '${_selectedCountryCode}${_phoneController.text.trim()}'
            : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          if (response.session == null) {
            _showEmailConfirmationDialog();
          } else {
            _showSuccessDialog();
          }
        } else {
          _showErrorSnackBar('Registration failed. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = e.toString().replaceFirst('Exception: ', '');

        // Handle specific Supabase errors
        if (errorMessage.contains('not initialized')) {
          _showErrorSnackBar(
              'Connection error. Please check your internet connection and try again.');
          await _checkSupabaseConnection();
        } else {
          _showErrorSnackBar(errorMessage);
        }
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showValidationErrors() {
    String errorMessage = '';

    if (!_isSupabaseConnected) {
      errorMessage = 'Database connection required';
    } else if (_usernameController.text.trim().isEmpty) {
      errorMessage = 'Please enter a username';
    } else if (!_isUsernameAvailable) {
      errorMessage = 'Please choose an available username';
    } else if (_emailController.text.trim().isEmpty) {
      errorMessage = 'Please enter your email';
    } else if (_emailError != null) {
      errorMessage = 'Please fix email errors';
    } else if (_passwordController.text.isEmpty) {
      errorMessage = 'Please enter a password';
    } else if (_passwordStrength < 0.3) {
      errorMessage = 'Please create a stronger password';
    } else if (_selectedDate == null) {
      errorMessage = 'Please select your birth date';
    } else if (!_isTermsAccepted) {
      errorMessage = 'Please accept the Terms & Privacy Policy';
    }

    if (errorMessage.isNotEmpty) {
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'mail_outline',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 60,
            ),
            SizedBox(height: 2.h),
            Text(
              'Check Your Email',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'We\'ve sent a confirmation email to ${_emailController.text}. Please check your email and click the confirmation link to activate your account.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
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
          _showErrorSnackBar('Facebook signup coming soon');
          setState(() {
            _isLoading = false;
          });
          return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$provider signin initiated...'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showErrorSnackBar(errorMessage);
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
            // Add connection status indicator
            if (_connectionError != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                color:
                    _isSupabaseConnected ? Colors.green : Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(
                      _isSupabaseConnected
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: _isSupabaseConnected ? Colors.white : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _isSupabaseConnected
                            ? 'Database connected successfully'
                            : _connectionError!,
                        style: TextStyle(
                          color:
                              _isSupabaseConnected ? Colors.white : Colors.red,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isSupabaseConnected)
                      TextButton(
                        onPressed: _checkSupabaseConnection,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: _connectionError != null ? 1.h : 4.h),
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

  Widget _buildCreateAccountButton() {
    final bool isEnabled =
        _isFormValid() && !_isLoading && _isSupabaseConnected;

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleRegistration : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
          foregroundColor: Colors.white,
          elevation: isEnabled ? 4 : 0,
          shadowColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(77),
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
                _isSupabaseConnected
                    ? 'Create Account'
                    : 'Connecting to Database...',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                      color:
                          AppTheme.lightTheme.colorScheme.primary.withAlpha(77),
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
        child: Column(
          children: [
            RegistrationForm(
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
            if (_showSuggestions && _usernameSuggestions.isNotEmpty)
              _buildUsernameSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSuggestions() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested usernames:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _usernameSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _onSuggestionTapped(suggestion),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          AppTheme.lightTheme.colorScheme.primary.withAlpha(77),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
      color: Colors.black.withAlpha(128),
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
