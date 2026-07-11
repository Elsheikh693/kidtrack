import '../../../../../index/index_main.dart';

/// Reusable friendly empty state (icon + title + subtitle) shared by the
/// reports when a period has no data.
class ReportEmptyState extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String subKey;

  const ReportEmptyState({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.subKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40.h),
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      child: Column(
        children: [
          Icon(icon, size: 60.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(titleKey.tr,
              textAlign: TextAlign.center,
              style: context.typography.mdMedium
                  .copyWith(color: const Color(0xFF64748B))),
          SizedBox(height: 6.h),
          Text(subKey.tr,
              textAlign: TextAlign.center,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
