import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BattleModeWidget extends StatelessWidget {
  final Map<String, dynamic> creator1;
  final Map<String, dynamic> creator2;
  final double tipPool;
  final String timeRemaining;

  const BattleModeWidget({
    super.key,
    required this.creator1,
    required this.creator2,
    required this.tipPool,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildBattleHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildCreatorSection(creator1, true)),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(child: _buildCreatorSection(creator2, false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.tertiary,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BATTLE MODE',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time: $timeRemaining',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TIP POOL',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${tipPool.toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorSection(Map<String, dynamic> creator, bool isLeft) {
    final double score = (creator['score'] as num?)?.toDouble() ?? 0.0;
    final double maxScore = 100.0;
    final double progress = score / maxScore;

    return Container(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(
                  'Creator ${isLeft ? '1' : '2'} Stream',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 3.w,
                      backgroundImage:
                          NetworkImage(creator['avatar'] as String? ?? ''),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        creator['name'] as String? ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLeft
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${score.toInt()} points',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
