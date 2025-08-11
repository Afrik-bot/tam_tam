import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialSignupButtons extends StatelessWidget {
  final VoidCallback? onGoogleSignup;
  final VoidCallback? onAppleSignup;
  final VoidCallback? onFacebookSignup;

  const SocialSignupButtons({
    Key? key,
    this.onGoogleSignup,
    this.onAppleSignup,
    this.onFacebookSignup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              onTap: onGoogleSignup,
              icon: 'g_translate',
              label: 'Google',
              backgroundColor: Colors.white,
              borderColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              textColor: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            _buildSocialButton(
              onTap: onAppleSignup,
              icon: 'apple',
              label: 'Apple',
              backgroundColor: Colors.black,
              borderColor: Colors.black,
              textColor: Colors.white,
            ),
            _buildSocialButton(
              onTap: onFacebookSignup,
              icon: 'facebook',
              label: 'Facebook',
              backgroundColor: const Color(0xFF1877F2),
              borderColor: const Color(0xFF1877F2),
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required String icon,
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: textColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
