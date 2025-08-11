import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentTabsWidget extends StatefulWidget {
  final bool isOwnProfile;
  final Function(int) onTabChanged;

  const ContentTabsWidget({
    Key? key,
    required this.isOwnProfile,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<ContentTabsWidget> createState() => _ContentTabsWidgetState();
}

class _ContentTabsWidgetState extends State<ContentTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isOwnProfile ? 4 : 3,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorPadding: EdgeInsets.all(2),
        labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'play_circle_filled',
                  color: _currentIndex == 0
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text("Videos"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'live_tv',
                  color: _currentIndex == 1
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text("Lives"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'token',
                  color: _currentIndex == 2
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text("NFTs"),
              ],
            ),
          ),
          if (widget.isOwnProfile)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'favorite',
                    color: _currentIndex == 3
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text("Liked"),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
