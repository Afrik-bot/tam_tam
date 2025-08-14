import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/social_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/content_tabs_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_info_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isCurrentUser = false;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user ID from route arguments or use current user
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    _userId = args ?? AuthService.currentUser?.id;
    _isCurrentUser = _userId == AuthService.currentUser?.id;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final profile = await SocialService.getUserProfile(_userId!);

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _refreshProfile() async {
    await _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : _userProfile == null
                ? _buildErrorState()
                : _buildProfileContent());
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              SizedBox(height: 30.h),
              Icon(Icons.person_outline, size: 80.sp, color: Colors.white54),
              SizedBox(height: 2.h),
              Text(
                  _isCurrentUser
                      ? 'Unable to load your profile'
                      : 'User not found',
                  style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
              SizedBox(height: 1.h),
              Text('Pull to refresh or try again later',
                  style:
                      GoogleFonts.inter(fontSize: 14.sp, color: Colors.white54),
                  textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              if (_isCurrentUser)
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Text('Sign In',
                        style: GoogleFonts.inter(
                            fontSize: 16.sp, fontWeight: FontWeight.w600))),
            ]));
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: CustomScrollView(slivers: [
          // Profile Header
          SliverToBoxAdapter(
              child: ProfileHeaderWidget(
            isOwnProfile: _isCurrentUser,
            userProfile: _convertToMap(_userProfile!),
          )),

          // Profile Info
          SliverToBoxAdapter(
              child: ProfileInfoWidget(
            userProfile: _convertToMap(_userProfile!),
          )),

          // Action Buttons
          if (!_isCurrentUser)
            SliverToBoxAdapter(
                child: ActionButtonsWidget(
              isOwnProfile: _isCurrentUser,
              userProfile: _convertToMap(_userProfile!),
            )),

          SliverToBoxAdapter(child: SizedBox(height: 2.h)),

          // Content Tabs
          ContentTabsWidget(
            isOwnProfile: _isCurrentUser,
            onTabChanged: (index) {},
          ),
        ]));
  }

  // Helper method to convert UserProfile to Map for backward compatibility with widgets
  Map<String, dynamic> _convertToMap(UserProfile profile) {
    return {
      'id': profile.id,
      'username': profile.username,
      'full_name': profile.fullName,
      'bio': profile.bio,
      'avatar_url': profile.avatarUrlWithFallback,
      'cover_image_url': profile.coverImageUrl,
      'verified': profile.verified,
      'followers_count': profile.followersCount,
      'following_count': profile.followingCount,
      'clout_score': profile.cloutScore,
      'total_tips_received': profile.totalTipsReceived,
      'role': profile.role.toString().split('.').last,
      'is_active': profile.isActive,
      'created_at': profile.createdAt.toIso8601String(),
    };
  }

  void _showProfileMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  margin: EdgeInsets.all(2.w),
                  height: 0.5.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(10))),
              ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: Text('Edit Profile',
                      style: GoogleFonts.inter(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _editProfile();
                  }),
              ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: Text('Settings',
                      style: GoogleFonts.inter(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  }),
              ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text('Sign Out',
                      style: GoogleFonts.inter(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  }),
              SizedBox(height: 2.h),
            ])));
  }

  Future<void> _handleFollow() async {
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    try {
      // Check if already following and toggle
      final isFollowing = await SocialService.isFollowing(_userId!);

      if (isFollowing) {
        await SocialService.unfollowUser(_userId!);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Unfollowed user')));
      } else {
        await SocialService.followUser(_userId!);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Following user')));
      }

      // Refresh profile to update follower count
      await _refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status: $e')));
    }
  }

  void _handleMessage() {
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    // Show message dialog or navigate to chat
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Send Message',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Messaging feature coming soon!',
                    style: GoogleFonts.inter(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF6B35)))),
                ]));
  }

  void _handleTip() {
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    // Navigate to tip screen or show tip dialog
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Send Tip',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Tipping feature coming soon!',
                    style: GoogleFonts.inter(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF6B35)))),
                ]));
  }

  void _editProfile() {
    // Navigate to edit profile screen
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Edit Profile',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Profile editing feature coming soon!',
                    style: GoogleFonts.inter(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF6B35)))),
                ]));
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to sign out: $e')));
    }
  }

  void _showAuthRequired() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Sign In Required',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Please sign in to perform this action',
                    style: GoogleFonts.inter(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(color: Colors.white54))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text('Sign In',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFF6B35)))),
                ]));
  }
}
