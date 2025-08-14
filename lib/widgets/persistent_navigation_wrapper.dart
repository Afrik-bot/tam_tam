import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../presentation/live_streaming_interface/live_streaming_interface.dart';
import '../presentation/main_video_feed/main_video_feed.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/video_creation_studio/video_creation_studio.dart';
import '../routes/app_routes.dart';

class PersistentNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const PersistentNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PersistentNavigationWrapper> createState() =>
      _PersistentNavigationWrapperState();
}

class _PersistentNavigationWrapperState
    extends State<PersistentNavigationWrapper> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const MainVideoFeed(),
    const LiveStreamingInterface(),
    const VideoCreationStudio(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == 3) {
      // Wallet tab - navigate to send money screen
      Navigator.pushNamed(context, AppRoutes.sendMoney);
    } else {
      setState(() {
        _currentIndex = index >= 3
            ? index - 1
            : index; // Adjust index for removed wallet screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 20,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex >= 3 ? _currentIndex + 1 : _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00D4FF),
          unselectedItemColor: const Color(0xFF666666),
          selectedFontSize: 12.sp,
          unselectedFontSize: 10.sp,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.live_tv,
                color: Colors.red, // Make Live icon red
              ),
              label: 'Live',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Create',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthRequiredScreen extends StatelessWidget {
  final String screenName;

  const _AuthRequiredScreen({required this.screenName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(screenName,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600)),
            automaticallyImplyLeading: false),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withAlpha(26),
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(
                      screenName == 'Wallet'
                          ? Icons.account_balance_wallet_outlined
                          : Icons.person_outline,
                      size: 80.sp,
                      color: const Color(0xFFFF6B35))),
              SizedBox(height: 4.h),
              Text('Join Tam Tam Community',
                  style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              SizedBox(height: 2.h),
              Text(
                  'Sign up to access your $screenName and unlock all the amazing features of Tam Tam!',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp, color: Colors.white70, height: 1.4),
                  textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.registration);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 5),
                      child: Text('Sign Up Now',
                          style: GoogleFonts.inter(
                              fontSize: 18.sp, fontWeight: FontWeight.w700)))),
              SizedBox(height: 2.h),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side:
                              const BorderSide(color: Colors.white54, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text('I Have an Account',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp, fontWeight: FontWeight.w600)))),
            ])));
  }
}
