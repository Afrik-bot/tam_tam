import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommentInputWidget extends StatelessWidget {
  final TextEditingController commentController;
  final VoidCallback onSendComment;
  final VoidCallback onGiftTap;
  final VoidCallback onShoppingTap;
  final bool hasProducts;

  const CommentInputWidget({
    super.key,
    required this.commentController,
    required this.onSendComment,
    required this.onGiftTap,
    required this.onShoppingTap,
    required this.hasProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 4.h,
      left: 4.w,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
                ),
                maxLines: 1,
                onSubmitted: (_) => onSendComment(),
              ),
            ),
            _buildActionButton(
              icon: 'send',
              onTap: onSendComment,
            ),
            SizedBox(width: 2.w),
            _buildActionButton(
              icon: 'card_giftcard',
              onTap: onGiftTap,
            ),
            if (hasProducts) ...[
              SizedBox(width: 2.w),
              _buildActionButton(
                icon: 'shopping_cart',
                onTap: onShoppingTap,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
