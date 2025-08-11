import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/audience_insights_widget.dart';
import './widgets/content_performance_widget.dart';
import './widgets/growth_trends_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/revenue_breakdown_widget.dart';
import './widgets/time_period_selector_widget.dart';

class CreatorAnalyticsDashboard extends StatefulWidget {
  const CreatorAnalyticsDashboard({super.key});

  @override
  State<CreatorAnalyticsDashboard> createState() =>
      _CreatorAnalyticsDashboardState();
}

class _CreatorAnalyticsDashboardState extends State<CreatorAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  bool _isRevenueExpanded = false;
  bool _isContentExpanded = false;
  bool _isAudienceExpanded = false;
  bool _isGrowthExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Simulate data refresh
    });
  }

  void _exportReport() {
    // Simulate PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Analytics report exported successfully!',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Creator Analytics',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/user-profile-screen'),
            icon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Goals'),
            Tab(text: 'Compare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildGoalsTab(),
          _buildCompareTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            TimePeriodSelectorWidget(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
            ),
            SizedBox(height: 2.h),
            _buildMetricsCards(),
            SizedBox(height: 2.h),
            RevenueBreakdownWidget(
              isExpanded: _isRevenueExpanded,
              onToggleExpanded: () {
                setState(() {
                  _isRevenueExpanded = !_isRevenueExpanded;
                });
              },
            ),
            ContentPerformanceWidget(
              isExpanded: _isContentExpanded,
              onToggleExpanded: () {
                setState(() {
                  _isContentExpanded = !_isContentExpanded;
                });
              },
            ),
            AudienceInsightsWidget(
              isExpanded: _isAudienceExpanded,
              onToggleExpanded: () {
                setState(() {
                  _isAudienceExpanded = !_isAudienceExpanded;
                });
              },
            ),
            GrowthTrendsWidget(
              isExpanded: _isGrowthExpanded,
              onToggleExpanded: () {
                setState(() {
                  _isGrowthExpanded = !_isGrowthExpanded;
                });
              },
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricsCardWidget(
                title: 'Total Earnings',
                value: '\$6,966.00',
                subtitle: '+15.2% from last period',
                iconName: 'attach_money',
                iconColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              MetricsCardWidget(
                title: 'Followers',
                value: '56.4K',
                subtitle: '+2.1K this week',
                iconName: 'people',
                iconColor: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricsCardWidget(
                title: 'Video Views',
                value: '8.2M',
                subtitle: '+890K this week',
                iconName: 'play_circle',
                iconColor: AppTheme.lightTheme.colorScheme.secondary,
              ),
              MetricsCardWidget(
                title: 'Clout Score',
                value: '8.7',
                subtitle: 'Elite Creator Level',
                iconName: 'star',
                iconColor: const Color(0xFFFFD700),
                showProgress: true,
                progressValue: 87,
                progressColor: const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Goals',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildGoalCard(
            'Earnings Target',
            '\$8,000',
            '\$6,966',
            87.1,
            AppTheme.lightTheme.colorScheme.primary,
            'attach_money',
          ),
          SizedBox(height: 2.h),
          _buildGoalCard(
            'Follower Goal',
            '60K',
            '56.4K',
            94.0,
            AppTheme.lightTheme.colorScheme.tertiary,
            'people',
          ),
          SizedBox(height: 2.h),
          _buildGoalCard(
            'Video Views',
            '10M',
            '8.2M',
            82.0,
            AppTheme.lightTheme.colorScheme.secondary,
            'play_circle',
          ),
          SizedBox(height: 2.h),
          _buildGoalCard(
            'Engagement Rate',
            '7.5%',
            '6.8%',
            90.7,
            const Color(0xFF00B894),
            'favorite',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String target, String current,
      double progress, Color color, String iconName) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: $current',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              Text(
                'Target: $target',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
          SizedBox(height: 1.h),
          Text(
            '${progress.toStringAsFixed(1)}% Complete',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benchmark Comparison',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Compare your performance with similar creators',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          _buildComparisonCard(
            'Average Earnings',
            '\$6,966',
            '\$4,200',
            '+65.9%',
            true,
            AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildComparisonCard(
            'Engagement Rate',
            '6.8%',
            '4.2%',
            '+61.9%',
            true,
            const Color(0xFF00B894),
          ),
          SizedBox(height: 2.h),
          _buildComparisonCard(
            'Follower Growth',
            '+24.8%',
            '+18.3%',
            '+6.5%',
            true,
            AppTheme.lightTheme.colorScheme.tertiary,
          ),
          SizedBox(height: 2.h),
          _buildComparisonCard(
            'Video Frequency',
            '12/week',
            '15/week',
            '-20.0%',
            false,
            const Color(0xFFE84393),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String metric, String yourValue, String avgValue,
      String difference, bool isPositive, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Performance',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    yourValue,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Industry Average',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    avgValue,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color: isPositive
                    ? const Color(0xFF00B894)
                    : const Color(0xFFE84393),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                difference,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isPositive
                      ? const Color(0xFF00B894)
                      : const Color(0xFFE84393),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                isPositive ? 'above average' : 'below average',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
