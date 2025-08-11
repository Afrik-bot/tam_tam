import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PortfolioValueCard extends StatefulWidget {
  final double totalValue;
  final double percentageChange;
  final bool isPositive;
  final VoidCallback onToggleVisibility;
  final bool isVisible;

  const PortfolioValueCard({
    Key? key,
    required this.totalValue,
    required this.percentageChange,
    required this.isPositive,
    required this.onToggleVisibility,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<PortfolioValueCard> createState() => _PortfolioValueCardState();
}

class _PortfolioValueCardState extends State<PortfolioValueCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Portfolio Value',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: CustomIconWidget(
                    iconName:
                        widget.isVisible ? 'visibility' : 'visibility_off',
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          widget.isVisible
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '\$${widget.totalValue.toStringAsFixed(2)}',
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                      decoration: BoxDecoration(
                        color: widget.isPositive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: widget.isPositive
                                ? 'trending_up'
                                : 'trending_down',
                            color:
                                widget.isPositive ? Colors.green : Colors.red,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${widget.isPositive ? '+' : ''}${widget.percentageChange.toStringAsFixed(2)}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color:
                                  widget.isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 8.h,
                  child: Center(
                    child: Text(
                      '••••••••',
                      style:
                          AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                        letterSpacing: 2.w,
                      ),
                    ),
                  ),
                ),
          SizedBox(height: 1.h),
          Text(
            'Last updated: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
