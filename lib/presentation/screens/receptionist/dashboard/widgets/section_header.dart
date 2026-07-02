import '../../../../../index/index_main.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget? trailing;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.accentColor = const Color(0xFF0891B2),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: context.typography.displaySmBold.copyWith(
              color: const Color(0xFF1E293B),
              letterSpacing: -0.1,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
