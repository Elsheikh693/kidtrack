import '../../../../../index/index_main.dart';

class ProfileChips extends StatelessWidget {
  final List<String> items;
  final bool filled;
  const ProfileChips({super.key, required this.items, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((e) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: AppText(
            text: e,
            textStyle: context.typography.xsMedium.copyWith(
              color: filled ? AppColors.white : AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ProfileProgramList extends StatelessWidget {
  final List<String> programs;
  const ProfileProgramList({super.key, required this.programs});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.w;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 10.h,
          children: programs.map((p) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.grayLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.school_rounded,
                          size: 18.sp, color: AppColors.primary),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AppText(
                        text: p,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
