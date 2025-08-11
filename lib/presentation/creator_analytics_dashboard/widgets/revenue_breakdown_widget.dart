import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RevenueBreakdownWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const RevenueBreakdownWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<RevenueBreakdownWidget> createState() => _RevenueBreakdownWidgetState();
}

class _RevenueBreakdownWidgetState extends State<RevenueBreakdownWidget> {
  final List<Map<String, dynamic>> revenueData = [
    {
      "source": "Tips",
      "amount": 2450.75,
      "percentage": 35.2,
      "color": const Color(0xFF6C5CE7),
      "transactions": 156
    },
    {
      "source": "Collaborations",
      "amount": 1890.50,
      "percentage": 27.1,
      "color": const Color(0xFFA29BFE),
      "transactions": 23
    },
    {
      "source": "Shopping",
      "amount": 1320.25,
      "percentage": 18.9,
      "color": const Color(0xFF00CEC9),
      "transactions": 89
    },
    {
      "source": "NFT Sales",
      "amount": 1305.00,
      "percentage": 18.8,
      "color": const Color(0xFF00B894),
      "transactions": 12
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggleExpanded,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Revenue Breakdown',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: widget.isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          widget.isExpanded
              ? Column(
                  children: [
                    Container(
                      height: 30.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: PieChart(
                        PieChartData(
                          sections: revenueData.map((data) {
                            return PieChartSectionData(
                              value: (data["percentage"] as double),
                              title: '${data["percentage"]}%',
                              color: data["color"] as Color,
                              radius: 60,
                              titleStyle: AppTheme
                                  .lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...revenueData.map((data) => _buildRevenueItem(data)),
                    SizedBox(height: 2.h),
                  ],
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Revenue',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${revenueData.fold(0.0, (sum, item) => sum + (item["amount"] as double)).toStringAsFixed(2)}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: data["color"] as Color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["source"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${data["transactions"]} transactions',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(data["amount"] as double).toStringAsFixed(2)}',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
