import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final bool isOwnProfile;
  final VoidCallback? onFollowTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onSettingsTap;

  const ProfileHeaderWidget({
    Key? key,
    required this.userProfile,
    required this.isOwnProfile,
    this.onFollowTap,
    this.onMessageTap,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      child: Stack(
        children: [
          // Cover Image
          Container(
            height: 25.h,
            width: double.infinity,
            child: CustomImageWidget(
              imageUrl: userProfile["coverImage"] as String? ??
                  "https://images.pexels.com/photos/1323550/pexels-photo-1323550.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
              width: double.infinity,
              height: 25.h,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Container(
            height: 25.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),

          // Profile Picture
          Positioned(
            top: 18.h,
            left: 6.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: userProfile["profileImage"] as String? ??
                      "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Settings/Follow Button
          Positioned(
            top: 20.h,
            right: 6.w,
            child: isOwnProfile
                ? GestureDetector(
                    onTap: onSettingsTap,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'settings',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onFollowTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: (userProfile["isFollowing"] as bool? ?? false)
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        (userProfile["isFollowing"] as bool? ?? false)
                            ? "Following"
                            : "Follow",
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: (userProfile["isFollowing"] as bool? ?? false)
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),

          // Verification Badge
          if (userProfile["isVerified"] as bool? ?? false)
            Positioned(
              top: 22.h,
              left: 22.w,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'verified',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 4.w,
                ),
              ),
            ),

          // VIP Badge
          if (userProfile["isVip"] as bool? ?? false)
            Positioned(
              top: 18.5.h,
              left: 22.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "VIP",
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
