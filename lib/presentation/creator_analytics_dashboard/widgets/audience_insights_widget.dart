import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudienceInsightsWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const AudienceInsightsWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<AudienceInsightsWidget> createState() => _AudienceInsightsWidgetState();
}

class _AudienceInsightsWidgetState extends State<AudienceInsightsWidget> {
  final List<Map<String, dynamic>> demographicsData = [
    {"age": "16-20", "percentage": 28.5, "color": const Color(0xFF6C5CE7)},
    {"age": "21-25", "percentage": 42.3, "color": const Color(0xFFA29BFE)},
    {"age": "26-30", "percentage": 19.8, "color": const Color(0xFF00CEC9)},
    {"age": "31+", "percentage": 9.4, "color": const Color(0xFF00B894)},
  ];

  final List<Map<String, dynamic>> geographicData = [
    {"country": "United States", "percentage": 35.2, "flag": "🇺🇸"},
    {"country": "Nigeria", "percentage": 18.7, "flag": "🇳🇬"},
    {"country": "India", "percentage": 15.3, "flag": "🇮🇳"},
    {"country": "Brazil", "percentage": 12.8, "flag": "🇧🇷"},
    {"country": "Others", "percentage": 18.0, "flag": "🌍"},
  ];

  final List<Map<String, dynamic>> activityData = [
    {"hour": "00", "activity": 12},
    {"hour": "03", "activity": 8},
    {"hour": "06", "activity": 15},
    {"hour": "09", "activity": 45},
    {"hour": "12", "activity": 78},
    {"hour": "15", "activity": 92},
    {"hour": "18", "activity": 85},
    {"hour": "21", "activity": 68},
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
                    'Audience Insights',
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
                    _buildDemographicsSection(),
                    _buildGeographicSection(),
                    _buildActivitySection(),
                    SizedBox(height: 2.h),
                  ],
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Primary Audience: 21-25 years',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '42.3%',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
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

  Widget _buildDemographicsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age Demographics',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 20.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < demographicsData.length) {
                          return Text(
                            demographicsData[index]["age"] as String,
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
                          '${value.toInt()}%',
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
                barGroups: demographicsData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value["percentage"] as double,
                        color: entry.value["color"] as Color,
                        width: 8.w,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildGeographicSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geographic Distribution',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...geographicData.map((data) => _buildGeographicItem(data)),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildGeographicItem(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Text(
            data["flag"] as String,
            style: const TextStyle(fontSize: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              data["country"] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '${(data["percentage"] as double).toStringAsFixed(1)}%',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peak Activity Times',
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
                        if (index >= 0 && index < activityData.length) {
                          return Text(
                            '${activityData[index]["hour"]}:00',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: activityData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value["activity"] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
