import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './custom_text_field.dart';

class LoginForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Email Field with enhanced validation
          CustomTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: emailErrorText,
              hint: 'Enter your email',
              iconName: 'email',
              label: 'Email',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                // Enhanced email validation
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              }),

          SizedBox(height: 2.h),

          // Password Field with enhanced validation
          CustomTextField(
              controller: passwordController,
              isPassword: true,
              errorText: passwordErrorText,
              hint: 'Enter your password',
              iconName: 'lock',
              label: 'Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              }),

          SizedBox(height: 1.h),

          // Forgot Password Link
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: onForgotPassword,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.w, vertical: 0.5.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Forgot Password?',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500)))),
        ]));
  }
}