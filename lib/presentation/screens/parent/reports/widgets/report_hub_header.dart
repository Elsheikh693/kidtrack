import '../../../../../index/index_main.dart';

/// Title block at the top of the Reports hub — the screen title and a
/// child-aware subtitle.
class ReportHubHeader extends StatelessWidget {
  const ReportHubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 2.h),
      child: Text(
        'reports_hub_title'.tr,
        style: context.typography.xlBold
            .copyWith(color: const Color(0xFF0F172A)),
      ),
    );
  }
}
