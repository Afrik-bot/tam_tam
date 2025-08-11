import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommentStreamWidget extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final ScrollController scrollController;

  const CommentStreamWidget({
    super.key,
    required this.comments,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 4.w,
      top: 20.h,
      bottom: 25.h,
      child: Container(
        width: 70.w,
        child: ListView.builder(
          controller: scrollController,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentItem(comment);
          },
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final String type = comment['type'] as String? ?? 'comment';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: type == 'tip'
          ? _buildTipNotification(comment)
          : _buildRegularComment(comment),
    );
  }

  Widget _buildRegularComment(Map<String, dynamic> comment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 2.w,
                backgroundImage:
                    NetworkImage(comment['avatar'] as String? ?? ''),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  comment['username'] as String? ?? 'Anonymous',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            comment['message'] as String? ?? '',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (comment['emoji'] != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              comment['emoji'] as String,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipNotification(Map<String, dynamic> tip) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.8),
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'card_giftcard',
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              '${tip['username']} sent ${tip['amount']}',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
