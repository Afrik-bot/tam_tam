import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationButtonsWidget extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onGetStarted;
  final bool isLastPage;

  const NavigationButtonsWidget({
    Key? key,
    this.onNext,
    this.onSkip,
    this.onGetStarted,
    required this.isLastPage,
  }) : super(key: key);

  @override
  State<NavigationButtonsWidget> createState() =>
      _NavigationButtonsWidgetState();
}

class _NavigationButtonsWidgetState extends State<NavigationButtonsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _buttonAnimationController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _buttonAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          // Main action button with enhanced animations
          AnimatedBuilder(
            animation: _buttonScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) => _onTapDown(),
                  onTapUp: (_) => _onTapUp(),
                  onTapCancel: () => _onTapUp(),
                  child: Container(
                    width: double.infinity,
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.primaryColor,
                          AppTheme.lightTheme.primaryColor.withAlpha(204),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppTheme.lightTheme.primaryColor.withAlpha(102),
                          blurRadius: _isPressed ? 8 : 12,
                          offset: Offset(0, _isPressed ? 2 : 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.isLastPage
                          ? widget.onGetStarted
                          : widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.isLastPage ? 'Get Started' : 'Next',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (!widget.isLastPage) ...[
                            SizedBox(width: 2.w),
                            AnimatedRotation(
                              turns: _isPressed ? 0.1 : 0.0,
                              duration: const Duration(milliseconds: 150),
                              child: const CustomIconWidget(
                                iconName: 'arrow_forward',
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                          if (widget.isLastPage) ...[
                            SizedBox(width: 2.w),
                            AnimatedScale(
                              scale: _isPressed ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: const CustomIconWidget(
                                iconName: 'rocket_launch',
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          if (!widget.isLastPage) ...[
            SizedBox(height: 2.h),

            // Skip button with hover effect
            AnimatedOpacity(
              opacity: widget.isLastPage ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: widget.onSkip,
                style: TextButton.styleFrom(
                  foregroundColor:
                      AppTheme.lightTheme.colorScheme.onSurface.withAlpha(179),
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withAlpha(179),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'arrow_forward',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withAlpha(128),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
