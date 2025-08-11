import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrencyCard extends StatefulWidget {
  final Map<String, dynamic> currency;
  final VoidCallback onTap;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;

  const CurrencyCard({
    Key? key,
    required this.currency,
    required this.onTap,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  }) : super(key: key);

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  double _dragOffset = 0.0;
  bool _isSwipeActive = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
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

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-100.0, 100.0);
      _isSwipeActive = _dragOffset.abs() > 30;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset > 50) {
      widget.onSwipeRight();
    } else if (_dragOffset < -50) {
      widget.onSwipeLeft();
    }

    setState(() {
      _dragOffset = 0.0;
      _isSwipeActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.currency;
    final isPositive = (currency['change'] as double) >= 0;

    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: _isSwipeActive
                ? Border.all(
                    color: _dragOffset > 0
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.blue.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Center(
                  child: currency['icon'] != null
                      ? CustomImageWidget(
                          imageUrl: currency['icon'] as String,
                          width: 8.w,
                          height: 8.w,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          (currency['symbol'] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency['name'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      currency['symbol'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${(currency['balance'] as double).toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.5.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName:
                              isPositive ? 'arrow_upward' : 'arrow_downward',
                          color: isPositive ? Colors.green : Colors.red,
                          size: 2.5.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${isPositive ? '+' : ''}${(currency['change'] as double).toStringAsFixed(2)}%',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
