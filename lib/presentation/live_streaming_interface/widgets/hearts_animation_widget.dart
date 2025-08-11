import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HeartsAnimationWidget extends StatefulWidget {
  final bool showAnimation;

  const HeartsAnimationWidget({
    super.key,
    required this.showAnimation,
  });

  @override
  State<HeartsAnimationWidget> createState() => _HeartsAnimationWidgetState();
}

class _HeartsAnimationWidgetState extends State<HeartsAnimationWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Animation<Offset>> _positionAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _positionAnimations = [];
  }

  @override
  void didUpdateWidget(HeartsAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation && !oldWidget.showAnimation) {
      _startHeartAnimation();
    }
  }

  void _startHeartAnimation() {
    for (int i = 0; i < 5; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 2000 + (i * 200)),
        vsync: this,
      );

      final scaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.3, curve: Curves.elasticOut),
      ));

      final positionAnimation = Tween<Offset>(
        begin: Offset(0.0, 0.0),
        end: Offset(
          (i - 2) * 0.3,
          -2.0 - (i * 0.2),
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _controllers.add(controller);
      _animations.add(scaleAnimation);
      _positionAnimations.add(positionAnimation);

      controller.forward().then((_) {
        controller.dispose();
      });

      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          controller.forward();
        }
      });
    }

    // Clean up after animation completes
    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _controllers.clear();
          _animations.clear();
          _positionAnimations.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _controllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controller = entry.value;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Positioned(
              left: 50.w + (_positionAnimations[index].value.dx * 10.w),
              bottom: 30.h + (_positionAnimations[index].value.dy * 10.h),
              child: Transform.scale(
                scale: _animations[index].value,
                child: CustomIconWidget(
                  iconName: 'favorite',
                  color: Colors.red,
                  size: 30 + (index * 5).toDouble(),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
