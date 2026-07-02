import 'package:flutter/material.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';

class ActivityPulseDot extends StatelessWidget {
  const ActivityPulseDot({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.activityGreenAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
      onEnd: () {},
    );
  }
}
