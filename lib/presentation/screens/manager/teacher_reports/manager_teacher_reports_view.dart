import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import 'models/teacher_report_models.dart';
import 'detail/teacher_day_detail_view.dart';
import 'widgets/tr_date_bar.dart';
import 'widgets/tr_summary_hero.dart';
import 'widgets/tr_activity_chart.dart';
import 'widgets/tr_teacher_card.dart';
import 'widgets/tr_shimmer.dart';
import 'widgets/tr_empty.dart';

/// Branch Manager screen: daily/period feedback from every teacher plus
/// performance charts. Read-only aggregation of completed classroom activities.
///
/// Renders in two modes:
/// • pushed route (default) — full screen with a back-button app bar.
/// • [asTab] — embedded as a bottom-nav tab in the manager shell, so it uses
///   the shared tab header (no back button) and inherits the shell's RTL.
class ManagerTeacherReportsView extends StatelessWidget {
  const ManagerTeacherReportsView({super.key, this.asTab = false});

  final bool asTab;

  static const _accent = AppColors.activityBlue;
  static const _bg = Color(0xFFF6F8FB);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagerTeacherReportsController>();

    if (asTab) {
      return Column(
        children: [
          ManagerTabHeader(title: 'tr_screen_title'.tr, accent: _accent),
          Expanded(
            child: ColoredBox(color: _bg, child: _body(context, controller)),
          ),
        ],
      );
    }

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            'tr_screen_title'.tr,
            style: context.typography.mdBold.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textDefault,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios_outlined,
                size: 18.sp, color: AppColors.textDefault),
            onPressed: Get.back,
          ),
        ),
        body: _body(context, controller),
      ),
    );
  }

  Widget _body(
      BuildContext context, ManagerTeacherReportsController controller) {
    return Obx(() {
      if (controller.isLoading.value) return const TrShimmer();
      final teachers = controller.teachers;
      final summary = controller.summary.value;
      final hasActive = teachers.any((t) => t.hasActivity);

      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: _accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TrDateBar(controller: controller, accent: _accent),
                  SizedBox(height: 20.h),
                  if (summary != null) ...[
                    TrSummaryHero(summary: summary, accent: _accent),
                    SizedBox(height: 20.h),
                  ],
                  if (!hasActive)
                    const TrEmpty(accent: _accent)
                  else ...[
                    TrActivityChart(teachers: teachers, accent: _accent),
                    SizedBox(height: 22.h),
                    _sectionHeader('tr_section_teachers'.tr),
                    SizedBox(height: 12.h),
                    for (final t in teachers) ...[
                      TrTeacherCard(
                        data: t,
                        accent: _accent,
                        showSparkline: !controller.isDayMode,
                        onTap: () => Get.to(
                          () => TeacherDayDetailView(
                            data: t,
                            rangeLabel: controller.isDayMode
                                ? 'tr_today'.tr
                                : controller.selectedRange.value.labelKey.tr,
                            isDayMode: controller.isDayMode,
                          ),
                          transition: Transition.cupertino,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ],
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionHeader(String title) => Row(
        children: [
          Container(
            width: 4.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDefault,
            ),
          ),
        ],
      );
}
