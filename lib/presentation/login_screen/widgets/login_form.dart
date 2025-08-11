import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool showEmailError;
  final bool showPasswordError;
  final String? emailErrorText;
  final String? passwordErrorText;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.showEmailError = false,
    this.showPasswordError = false,
    this.emailErrorText,
    this.passwordErrorText,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email address',
            iconName: 'email',
            keyboardType: TextInputType.emailAddress,
            controller: widget.emailController,
            validator: _validateEmail,
            showError: widget.showEmailError,
            errorText: widget.emailErrorText,
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            iconName: 'lock',
            isPassword: true,
            controller: widget.passwordController,
            validator: _validatePassword,
            showError: widget.showPasswordError,
            errorText: widget.passwordErrorText,
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              ),
              child: Text(
                'Forgot Password?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
