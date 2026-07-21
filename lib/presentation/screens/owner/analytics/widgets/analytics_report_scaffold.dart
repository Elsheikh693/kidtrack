import '../../../../../index/index_main.dart';

/// Shared shell for every analytics report screen: the owner app bar (with the
/// scope switcher + a back arrow), pull-to-refresh, a cold-start skeleton, and a
/// scrolling body. [children] is rebuilt inside an [Obx], so any controller Rx
/// it reads (dashboard data, scope) drives the rebuild — no per-report workers.
class AnalyticsReportScaffold extends StatelessWidget {
  final String titleKey;
  final RxBool loading;
  final Future<void> Function() onRefresh;
  final List<Widget> Function(BuildContext) children;

  /// Network-level reports (parent engagement, evaluations…) that can't slice by
  /// branch hide the scope switcher so it isn't a dead control.
  final bool showScope;

  /// When set, a PDF-export action appears in the app bar.
  final Future<void> Function()? onExport;

  const AnalyticsReportScaffold({
    super.key,
    required this.titleKey,
    required this.loading,
    required this.onRefresh,
    required this.children,
    this.showScope = true,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: titleKey.tr,
        showScopeSwitcher: showScope,
        onBack: () => Get.back(),
        extraActions: onExport == null
            ? const []
            : [
                IconButton(
                  tooltip: 'owner_report_export_pdf'.tr,
                  icon: const Icon(Icons.ios_share_rounded, size: 21),
                  color: AppColors.textDefault,
                  onPressed: onExport,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        child: Obx(
          () => ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children:
                loading.value ? _skeleton() : children(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _skeleton() => [
        for (var i = 0; i < 4; i++)
          Container(
            height: i == 0 ? 120.h : 74.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
      ];
}
