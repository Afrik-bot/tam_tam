import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipientInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function() onQRScan;
  final Function(String) onRecipientChanged;

  const RecipientInputWidget({
    super.key,
    required this.controller,
    required this.onQRScan,
    required this.onRecipientChanged,
  });

  @override
  State<RecipientInputWidget> createState() => _RecipientInputWidgetState();
}

class _RecipientInputWidgetState extends State<RecipientInputWidget> {
  bool _isValidRecipient = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateRecipient);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateRecipient);
    super.dispose();
  }

  void _validateRecipient() {
    final text = widget.controller.text;
    final isValid = _isValidEmail(text) ||
        _isValidPhone(text) ||
        _isValidUsername(text) ||
        _isValidWalletAddress(text);

    if (_isValidRecipient != isValid) {
      setState(() {
        _isValidRecipient = isValid;
      });
    }
    widget.onRecipientChanged(text);
  }

  bool _isValidEmail(String text) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
  }

  bool _isValidPhone(String text) {
    return RegExp(r'^\+?[1-9]\d{1,14}$')
        .hasMatch(text.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  bool _isValidUsername(String text) {
    return RegExp(r'^@?[a-zA-Z0-9_]{3,20}$').hasMatch(text);
  }

  bool _isValidWalletAddress(String text) {
    return text.length >= 26 &&
        text.length <= 62 &&
        RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
  }

  String _getInputType() {
    final text = widget.controller.text;
    if (_isValidEmail(text)) return 'Email';
    if (_isValidPhone(text)) return 'Phone';
    if (_isValidUsername(text)) return 'Username';
    if (_isValidWalletAddress(text)) return 'Wallet Address';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isValidRecipient
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Send To',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_isValidRecipient) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _getInputType(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: widget.controller,
            style: AppTheme.lightTheme.textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: 'Username, email, phone, or wallet address',
              hintStyle: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              suffixIcon: Container(
                margin: EdgeInsets.all(1.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.controller.text.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          widget.controller.clear();
                          widget.onRecipientChanged('');
                        },
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                    ],
                    GestureDetector(
                      onTap: widget.onQRScan,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'qr_code_scanner',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
          ),
          if (widget.controller.text.isNotEmpty && !_isValidRecipient) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Please enter a valid username, email, phone number, or wallet address',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
