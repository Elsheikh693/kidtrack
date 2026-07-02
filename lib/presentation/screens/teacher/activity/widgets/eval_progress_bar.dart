import 'package:flutter/material.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';

class EvalProgressBar extends StatelessWidget {
  const EvalProgressBar({
    super.key,
    required this.excellent,
    required this.follow,
    required this.attention,
    required this.total,
  });

  final int excellent;
  final int follow;
  final int attention;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 5,
        child: Row(
          children: [
            if (excellent > 0)
              Flexible(
                flex: excellent,
                child: Container(color: AppColors.activityGreen),
              ),
            if (follow > 0)
              Flexible(
                flex: follow,
                child: Container(color: AppColors.activityAmber),
              ),
            if (attention > 0)
              Flexible(
                flex: attention,
                child: Container(color: AppColors.activityRed),
              ),
          ],
        ),
      ),
    );
  }
}
