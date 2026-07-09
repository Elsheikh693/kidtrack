import '../../../../../index/index_main.dart';
import '../models/setup_step.dart';

class SetupHubStepCard extends StatelessWidget {
  final SetupChecklistController controller;
  final SetupStep step;
  const SetupHubStepCard({
    super.key,
    required this.controller,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final done = controller.isDone(step.id);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: done
              ? AppColors.successBackground.withValues(alpha: 0.35)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => controller.openStep(step),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: done
                      ? AppColors.successForeground.withValues(alpha: 0.5)
                      : AppColors.borderNeutralPrimary.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.successBackground
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  step.icon,
                  size: 22.sp,
                  color:
                      done ? AppColors.successForeground : AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.titleKey.tr,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      step.subtitleKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              if (done)
                Icon(Icons.check_circle_rounded,
                    size: 24.sp, color: AppColors.successForeground)
              else
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16.sp, color: AppColors.grayMedium),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
