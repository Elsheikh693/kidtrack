import '../../../../../../index/index_main.dart';
import '../../../teacher_reports/widgets/tr_format.dart';

/// Teacher summary banner atop the day drill-down: avatar, name and a one-line
/// count of today's activities.
class TtHeader extends StatelessWidget {
  const TtHeader({
    super.key,
    required this.name,
    required this.photo,
    required this.accent,
    required this.count,
  });

  final String name;
  final String? photo;
  final Color accent;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [accent, Color.lerp(accent, Colors.black, 0.32)!],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            backgroundImage: (photo != null && photo!.isNotEmpty)
                ? appCachedImageProvider(photo!)
                : null,
            child: (photo == null || photo!.isEmpty)
                ? Text(
                    trInitial(name),
                    style: context.typography.xlBold.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'live_teaching_today_count'.trParams({'count': '$count'}),
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
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
