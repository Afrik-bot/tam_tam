import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

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
          _buildBirthDateField(),
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
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: InputDecoration(
            labelText: 'Username *',
            hintText: 'Enter your username',
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: _buildUsernameStatusIcon(),
            errorText: widget.usernameError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                .withAlpha(26),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
        ),
        if (widget.usernameController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, left: 1.w),
            child: Text(
              widget.isCheckingUsername
                  ? 'Checking availability...'
                  : widget.isUsernameAvailable
                      ? '✓ Username is available'
                      : widget.usernameError ?? '',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: widget.isCheckingUsername
                    ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    : widget.isUsernameAvailable
                        ? Colors.green
                        : AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildUsernameStatusIcon() {
    if (widget.isCheckingUsername) {
      return Padding(
        padding: EdgeInsets.all(2.w),
        child: SizedBox(
          width: 4.w,
          height: 4.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (widget.usernameController.text.isNotEmpty) {
      return Icon(
        widget.isUsernameAvailable ? Icons.check_circle : Icons.error,
        color: widget.isUsernameAvailable
            ? Colors.green
            : AppTheme.lightTheme.colorScheme.error,
        size: 5.w,
      );
    }

    return null;
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      onChanged: widget.onEmailChanged,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email *',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email_outlined),
        errorText: widget.emailError,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withAlpha(26),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 20.w,
          child: DropdownButtonFormField<String>(
            value: widget.selectedCountryCode,
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.onCountryCodeChanged(newValue);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withAlpha(26),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            ),
            items: const [
              DropdownMenuItem(value: '+1', child: Text('+1')),
              DropdownMenuItem(value: '+44', child: Text('+44')),
              DropdownMenuItem(value: '+91', child: Text('+91')),
              DropdownMenuItem(value: '+86', child: Text('+86')),
              DropdownMenuItem(value: '+81', child: Text('+81')),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: TextFormField(
            controller: widget.phoneController,
            onChanged: widget.onPhoneChanged,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              errorText: widget.phoneError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withAlpha(26),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Please enter only numbers';
                }
              }
              return null;
            },
          ),
        ),
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
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Create a password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            errorText: widget.passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                .withAlpha(26),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        if (widget.passwordController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: widget.passwordStrength,
                  backgroundColor:
                      AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPasswordStrengthColor(),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getPasswordStrengthText(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getPasswordStrengthColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getPasswordStrengthColor() {
    if (widget.passwordStrength < 0.3) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (widget.passwordStrength < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getPasswordStrengthText() {
    if (widget.passwordStrength < 0.3) {
      return 'Weak password';
    } else if (widget.passwordStrength < 0.7) {
      return 'Good password';
    } else {
      return 'Strong password';
    }
  }

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
              .withAlpha(26),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                widget.selectedDate == null
                    ? 'Birth Date *'
                    : '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: widget.selectedDate == null
                      ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now()
          .subtract(const Duration(days: 365 * 13)), // 13+ years old
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.isTermsAccepted,
          onChanged: (bool? value) {
            widget.onTermsChanged(value ?? false);
          },
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              widget.onTermsChanged(!widget.isTermsAccepted);
            },
            child: Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
