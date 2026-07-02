import '../../../../../index/index_main.dart';
import '../controller.dart';

class OccupancyCard extends StatelessWidget {
  final ClassOccupancyData data;
  const OccupancyCard({super.key, required this.data});

  Color get _color {
    if (data.isFull) return const Color(0xFFDC2626);
    if (data.isAlmostFull) return const Color(0xFFF97316);
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: () => Get.toNamed(classroomsView),
      child: Container(
        width: 128.w,
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    data.isFull
                        ? 'reception_occupancy_full'.tr
                        : data.isAlmostFull
                            ? 'reception_occupancy_almost'.tr
                            : 'reception_occupancy_open'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.class_rounded, size: 14.sp, color: color.withValues(alpha: 0.6)),
              ],
            ),
            Text(
              data.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${data.enrolled}',
                      style: context.typography.xlBold.copyWith(
                        color: color,
                        height: 1,
                      ),
                    ),
                    Text(
                      ' / ${data.capacity}',
                      style: context.typography.xsMedium.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: data.fillRate,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5.h,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
