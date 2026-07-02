import '../../../../index/index_main.dart';
import 'teacher_reports_controller.dart';
import 'widgets/report_activity_shimmer.dart';

const _kGreen = Color(0xFF16A34A);
const _kBg = Color(0xFFF8FAFC);

class TeacherReportsTab extends StatelessWidget {
  const TeacherReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TeacherReportsController>();
    return ColoredBox(
      color: _kBg,
      child: Column(
        children: [
          _Header(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const ReportActivityShimmer();
              }
              return RefreshIndicator(
                color: _kGreen,
                onRefresh: ctrl.reload,
                child: Obx(() {
                  final activities = ctrl.displayedActivities;
                  if (activities.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: 80.h),
                        const _EmptyState(),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                    itemCount: activities.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatsCard(ctrl: ctrl),
                            SizedBox(height: 22.h),
                            _SectionLabel(
                              label:
                                  'الأنشطة المكتملة  (${activities.length})',
                            ),
                            SizedBox(height: 12.h),
                          ],
                        );
                      }
                      final a = activities[i - 1];
                      final ch = ctrl.childrenForActivity(a);
                      return ReportActivityCard(
                        activity: a,
                        children: ch,
                        onTap: () => Get.to(
                          () => const ActivityReportView(),
                          arguments: {'activity': a, 'children': ch},
                          transition: Transition.rightToLeft,
                        ),
                      );
                    },
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.ctrl});
  final TeacherReportsController ctrl;

  static String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'teacher_tab_reports'.tr,
                    style: context.typography.lgBold,
                  ),
                  const Spacer(),
                  _DateBadge(label: _todayLabel()),
                ],
              ),
            ),
            if (ctrl.classrooms.length > 1) ...[
              Container(
                height: 1.h,
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.2),
              ),
              SizedBox(
                height: 54.h,
                child: Obx(
                  () => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    itemCount: ctrl.classrooms.length + 1,
                    separatorBuilder: (_, $2) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return _ClassChip(
                          label: 'teacher_report_all_classes'.tr,
                          isSelected:
                              ctrl.selectedClassroomId.value == 'all',
                          onTap: () => ctrl.selectClassroom('all'),
                        );
                      }
                      final c = ctrl.classrooms[i - 1];
                      return _ClassChip(
                        label: c.name,
                        isSelected:
                            ctrl.selectedClassroomId.value == c.key,
                        onTap: () => ctrl.selectClassroom(c.key ?? ''),
                      );
                    },
                  ),
                ),
              ),
            ],
            Container(
              height: 1.h,
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 13.sp,
            color: const Color(0xFF64748B),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 12,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  const _ClassChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? _kGreen : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: context.typography.smSemiBold.copyWith(
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

// ── Stats Card ─────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.ctrl});
  final TeacherReportsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF14532D), Color(0xFF16A34A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.35),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ملخص اليوم',
                  style: context.typography.displaySmBold.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'اليوم',
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _StatItem(
                  icon: Icons.play_circle_rounded,
                  value: '${ctrl.totalActivities}',
                  label: 'نشاط',
                ),
                _VDivider(),
                _StatItem(
                  icon: Icons.people_rounded,
                  value: '${ctrl.participatingStudents}',
                  label: 'طالب',
                ),
                _VDivider(),
                _StatItem(
                  icon: Icons.check_circle_rounded,
                  value: '${ctrl.totalEvaluations}',
                  label: 'تقييم',
                ),
                _VDivider(),
                _StatItem(
                  icon: Icons.bar_chart_rounded,
                  value: ctrl.averageRating == 0
                      ? '—'
                      : ctrl.averageRating.toStringAsFixed(1),
                  label: 'متوسط',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.75), size: 17.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: context.typography.xlBold.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1.w,
        height: 44.h,
        color: Colors.white.withValues(alpha: 0.18),
      );
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.typography.displaySmBold.copyWith(
        fontSize: 15,
        color: const Color(0xFF0F172A),
        letterSpacing: -0.2,
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(26.w),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assessment_rounded,
                size: 52.sp,
                color: _kGreen,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'teacher_report_empty_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'teacher_report_empty_sub'.tr,
              style: context.typography.xsRegular.copyWith(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
