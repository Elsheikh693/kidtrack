import '../../../../index/index_main.dart';

/// Skeleton placeholder for the "Learn the App" list while videos load.
class TutorialShimmer extends StatelessWidget {
  const TutorialShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18.r)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 180.w, height: 14.h, color: AppColors.white),
                    SizedBox(height: 8.h),
                    Container(
                        width: 120.w, height: 12.h, color: AppColors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
