import '../../../../../index/index_main.dart';

class ActivityFeedTile extends StatelessWidget {
  final ChildAttendanceModel record;
  const ActivityFeedTile({super.key, required this.record});

  bool get _isCheckout => record.checkOutTime != null;

  IconData get _icon =>
      _isCheckout ? Icons.logout_rounded : Icons.login_rounded;

  Color get _color =>
      _isCheckout ? const Color(0xFFF97316) : const Color(0xFF0891B2);

  String get _label =>
      _isCheckout ? 'activity_checkout'.tr : 'activity_checkin'.tr;

  String _formatTime(int? ms) {
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final time = _isCheckout
        ? _formatTime(record.checkOutTime)
        : _formatTime(record.checkInTime);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 17.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_label} • ${record.childId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smMedium
                      .copyWith(color: AppColors.textDefault, fontSize: 13),
                ),
                if (record.status == 'late')
                  Text(
                    'attendance_status_late'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: const Color(0xFFF97316),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            time,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
