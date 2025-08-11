import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final Function(String) onUsernameChanged;
  final Function(String) onEmailChanged;
  final Function(String) onPhoneChanged;
  final Function(String) onPasswordChanged;
  final bool isUsernameAvailable;
  final bool isCheckingUsername;
  final String? usernameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final double passwordStrength;
  final String selectedCountryCode;
  final Function(String) onCountryCodeChanged;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isTermsAccepted;
  final Function(bool) onTermsChanged;

  const RegistrationForm({
    Key? key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onUsernameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onPasswordChanged,
    required this.isUsernameAvailable,
    required this.isCheckingUsername,
    this.usernameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    required this.passwordStrength,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.selectedDate,
    required this.onDateSelected,
    required this.isTermsAccepted,
    required this.onTermsChanged,
  }) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  bool _isPasswordVisible = false;
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+234', 'country': 'NG'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+55', 'country': 'BR'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+82', 'country': 'KR'},
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsernameField(),
          SizedBox(height: 2.h),
          _buildEmailField(),
          SizedBox(height: 2.h),
          _buildPhoneField(),
          SizedBox(height: 2.h),
          _buildPasswordField(),
          SizedBox(height: 2.h),
          _buildDatePicker(),
          SizedBox(height: 3.h),
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.usernameController,
          onChanged: widget.onUsernameChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: widget.isCheckingUsername
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : widget.usernameController.text.isNotEmpty
                    ? CustomIconWidget(
                        iconName: widget.isUsernameAvailable
                            ? 'check_circle'
                            : 'cancel',
                        color: widget.isUsernameAvailable
                            ? Colors.green
                            : AppTheme.lightTheme.colorScheme.error,
                        size: 20,
                      )
                    : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        if (widget.usernameError != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            widget.usernameError!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.emailController,
          onChanged: widget.onEmailChanged,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: CustomIconWidget(
              iconName: 'email',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        if (widget.emailError != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            widget.emailError!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 25.w,
              child: DropdownButtonFormField<String>(
                value: widget.selectedCountryCode,
                decoration: InputDecoration(
                  labelText: 'Code',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                ),
                items: _countryCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text(
                      '${country['code']} ${country['country']}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onCountryCodeChanged(value);
                  }
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                onChanged: widget.onPhoneChanged,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  prefixIcon: CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (widget.phoneError != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            widget.phoneError!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.passwordController,
          onChanged: widget.onPasswordChanged,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: CustomIconWidget(
                iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        if (widget.passwordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          _buildPasswordStrengthIndicator(),
        ],
        if (widget.passwordError != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            widget.passwordError!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    Color strengthColor;
    String strengthText;

    if (widget.passwordStrength < 0.3) {
      strengthColor = AppTheme.lightTheme.colorScheme.error;
      strengthText = 'Weak';
    } else if (widget.passwordStrength < 0.7) {
      strengthColor = Colors.orange;
      strengthText = 'Medium';
    } else {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: widget.passwordStrength,
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              strengthText,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.selectedDate ??
              DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: AppTheme.lightTheme.colorScheme,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          widget.onDateSelected(picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.lightTheme.colorScheme.surface,
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                widget.selectedDate != null
                    ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                    : 'Select your birth date (16+ required)',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: widget.selectedDate != null
                      ? AppTheme.lightTheme.colorScheme.onSurface
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_drop_down',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.isTermsAccepted,
          onChanged: (value) {
            widget.onTermsChanged(value ?? false);
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              widget.onTermsChanged(!widget.isTermsAccepted);
            },
            child: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
