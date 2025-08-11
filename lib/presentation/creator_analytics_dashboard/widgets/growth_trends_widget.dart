import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GrowthTrendsWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const GrowthTrendsWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<GrowthTrendsWidget> createState() => _GrowthTrendsWidgetState();
}

class _GrowthTrendsWidgetState extends State<GrowthTrendsWidget> {
  final List<Map<String, dynamic>> followerGrowthData = [
    {"date": "Aug 1", "followers": 45200},
    {"date": "Aug 3", "followers": 46800},
    {"date": "Aug 5", "followers": 48500},
    {"date": "Aug 7", "followers": 51200},
    {"date": "Aug 9", "followers": 53800},
    {"date": "Aug 11", "followers": 56400},
  ];

  final List<Map<String, dynamic>> engagementData = [
    {"date": "Aug 1", "rate": 4.2},
    {"date": "Aug 3", "rate": 4.8},
    {"date": "Aug 5", "rate": 5.1},
    {"date": "Aug 7", "rate": 5.7},
    {"date": "Aug 9", "rate": 6.2},
    {"date": "Aug 11", "rate": 6.8},
  ];

  final List<Map<String, dynamic>> earningsProjection = [
    {"month": "Sep", "projected": 3200},
    {"month": "Oct", "projected": 3800},
    {"month": "Nov", "projected": 4500},
    {"month": "Dec", "projected": 5200},
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
                    'Growth Trends',
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
                    _buildFollowerGrowthSection(),
                    _buildEngagementSection(),
                    _buildEarningsProjectionSection(),
                    SizedBox(height: 2.h),
                  ],
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Follower Growth Rate',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'trending_up',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '+24.8%',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFollowerGrowthSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follower Growth',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 20.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < followerGrowthData.length) {
                          return Text(
                            followerGrowthData[index]["date"] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: followerGrowthData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value["followers"] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: AppTheme.lightTheme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildEngagementSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Rate Trend',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 15.h,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < engagementData.length) {
                          return Text(
                            engagementData[index]["date"] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}%',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: engagementData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value["rate"] as double,
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildEarningsProjectionSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Projection',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...earningsProjection.map((data) => _buildProjectionItem(data)),
        ],
      ),
    );
  }

  Widget _buildProjectionItem(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data["month"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Row(
            children: [
              Text(
                '\$${(data["projected"] as int).toString()}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
