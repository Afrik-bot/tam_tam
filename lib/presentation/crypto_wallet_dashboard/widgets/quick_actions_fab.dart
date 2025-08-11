import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsFab extends StatefulWidget {
  final VoidCallback onSendMoney;
  final VoidCallback onRequestPayment;
  final VoidCallback onBuyCrypto;

  const QuickActionsFab({
    Key? key,
    required this.onSendMoney,
    required this.onRequestPayment,
    required this.onBuyCrypto,
  }) : super(key: key);

  @override
  State<QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<QuickActionsFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildActionButton({
    required String iconName,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required double offset,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -offset * _scaleAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: () {
                onTap();
                _toggleExpansion();
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(2.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3.w),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: iconName,
                          color: Colors.white,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildActionButton(
            iconName: 'currency_bitcoin',
            label: 'Buy Crypto',
            onTap: widget.onBuyCrypto,
            color: Colors.orange,
            offset: 60,
          ),
          _buildActionButton(
            iconName: 'request_quote',
            label: 'Request Payment',
            onTap: widget.onRequestPayment,
            color: Colors.blue,
            offset: 40,
          ),
          _buildActionButton(
            iconName: 'send',
            label: 'Send Money',
            onTap: widget.onSendMoney,
            color: Colors.green,
            offset: 20,
          ),
        ],
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: FloatingActionButton(
                onPressed: _toggleExpansion,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'add',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
