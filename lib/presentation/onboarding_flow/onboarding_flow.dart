import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/navigation_buttons_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/progress_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Create Viral Content",
      "subtitle":
          "Use AI-powered editing tools and auto-cut features to create trending videos that capture millions of views",
      "imageUrl":
          "https://images.unsplash.com/photo-1611162617474-5b21e879e113?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFF6C5CE7),
      "textColor": Colors.white,
    },
    {
      "title": "Earn Real Money",
      "subtitle":
          "Monetize your creativity through tips, brand partnerships, and our revolutionary Tam Token rewards system",
      "imageUrl":
          "https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "backgroundColor": const Color(0xFF00B894),
      "textColor": Colors.white,
    },
    {
      "title": "Connect & Collaborate",
      "subtitle":
          "Find your creative tribe with Tam Crush matching and split-screen collaboration features",
      "imageUrl":
          "https://images.pixabay.com/photo/2020/05/18/16/17/social-media-5187243_1280.png",
      "backgroundColor": const Color(0xFFE84393),
      "textColor": Colors.white,
    },
    {
      "title": "Crypto Wallet Built-In",
      "subtitle":
          "Send money, buy crypto, and manage your earnings with our secure multi-currency wallet",
      "imageUrl":
          "https://images.unsplash.com/photo-1639762681485-074b7f938ba0?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFF00CEC9),
      "textColor": Colors.white,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _triggerHapticFeedback();
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _triggerHapticFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0 &&
                _currentPage < _totalPages - 1) {
              _nextPage();
            } else if (details.primaryVelocity! > 0 && _currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              _triggerHapticFeedback();
            }
          }
        },
        child: Stack(
          children: [
            // Page view with onboarding screens
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: OnboardingPageWidget(
                    title: data["title"] as String,
                    subtitle: data["subtitle"] as String,
                    imageUrl: data["imageUrl"] as String,
                    backgroundColor: data["backgroundColor"] as Color,
                    textColor: data["textColor"] as Color,
                  ),
                );
              },
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 2.h,
              right: 6.w,
              child: GestureDetector(
                onTap: _skipOnboarding,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Progress indicator
            Positioned(
              top: MediaQuery.of(context).padding.top + 1.h,
              left: 0,
              right: 0,
              child: ProgressIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
              ),
            ),

            // Navigation buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: NavigationButtonsWidget(
                  isLastPage: _currentPage == _totalPages - 1,
                  onNext: _nextPage,
                  onSkip: _skipOnboarding,
                  onGetStarted: _getStarted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
