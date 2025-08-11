import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentRecipientsWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onRecipientSelected;

  const RecentRecipientsWidget({
    super.key,
    required this.onRecipientSelected,
  });

  @override
  Widget build(BuildContext context) {
    final recentRecipients = [
      {
        "id": "1",
        "name": "Sarah Chen",
        "username": "@sarahc",
        "avatar":
            "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
        "lastTransaction": "2 days ago",
        "type": "username"
      },
      {
        "id": "2",
        "name": "Marcus Johnson",
        "username": "@marcusj",
        "avatar":
            "https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400",
        "lastTransaction": "1 week ago",
        "type": "username"
      },
      {
        "id": "3",
        "name": "Elena Rodriguez",
        "username": "@elenarodz",
        "avatar":
            "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
        "lastTransaction": "3 days ago",
        "type": "username"
      },
      {
        "id": "4",
        "name": "David Kim",
        "username": "@davidkim",
        "avatar":
            "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
        "lastTransaction": "5 days ago",
        "type": "username"
      },
      {
        "id": "5",
        "name": "Priya Patel",
        "username": "@priyap",
        "avatar":
            "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400",
        "lastTransaction": "1 day ago",
        "type": "username"
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recent Recipients',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentRecipients.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final recipient = recentRecipients[index];
                return GestureDetector(
                  onTap: () => onRecipientSelected(recipient),
                  child: Container(
                    width: 16.w,
                    child: Column(
                      children: [
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: recipient["avatar"] as String,
                              width: 16.w,
                              height: 16.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          (recipient["name"] as String).split(' ')[0],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
