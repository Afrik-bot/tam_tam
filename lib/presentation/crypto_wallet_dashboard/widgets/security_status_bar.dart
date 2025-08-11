import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecurityStatusBar extends StatelessWidget {
  final bool isSecureConnection;
  final bool isWalletSynced;
  final DateTime lastSyncTime;

  const SecurityStatusBar({
    Key? key,
    required this.isSecureConnection,
    required this.isWalletSynced,
    required this.lastSyncTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSecureConnection && isWalletSynced
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isSecureConnection ? 'security' : 'warning',
            color: isSecureConnection ? Colors.green : Colors.orange,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              isSecureConnection
                  ? 'Secure Connection • Wallet ${isWalletSynced ? 'Synced' : 'Syncing...'}'
                  : 'Connection Issues • Check Network',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSecureConnection ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ),
          if (isWalletSynced) ...[
            CustomIconWidget(
              iconName: 'sync',
              color: Colors.green,
              size: 3.w,
            ),
            SizedBox(width: 1.w),
            Text(
              '${lastSyncTime.hour.toString().padLeft(2, '0')}:${lastSyncTime.minute.toString().padLeft(2, '0')}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontSize: 9.sp,
              ),
            ),
          ] else ...[
            SizedBox(
              width: 3.w,
              height: 3.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
