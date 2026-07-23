import '../../../../index/index_main.dart';
import 'homework_tab_controller.dart';
import 'widgets/hw_report_card.dart';
import 'widgets/hw_report_shimmer.dart';

const _kBlue = Color(0xFF2563EB);
const _kBg = Color(0xFFF8FAFC);

// ── Main Tab ──────────────────────────────────────────────────────────────────

class TeacherHomeworkTab extends StatefulWidget {
  const TeacherHomeworkTab({super.key});

  @override
  State<TeacherHomeworkTab> createState() => _TeacherHomeworkTabState();
}

class _TeacherHomeworkTabState extends State<TeacherHomeworkTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) => CurvedAnimation(
    parent: _ctrl,
    curve: Interval(start, end, curve: Curves.easeOut),
  );

  Animation<Offset> _slide(double start, double end, Offset from) =>
      Tween<Offset>(begin: from, end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeworkTabController>();
    return ColoredBox(
      color: _kBg,
      child: Column(
        children: [
          // Header slides in from top
          FadeTransition(
            opacity: _fade(0.0, 0.55),
            child: SlideTransition(
              position: _slide(0.0, 0.55, const Offset(0, -0.3)),
              child: _Header(ctrl: ctrl),
            ),
          ),
          // Body fades in + slides up from bottom
          Expanded(
            child: FadeTransition(
              opacity: _fade(0.2, 1.0),
              child: SlideTransition(
                position: _slide(0.2, 1.0, const Offset(0, 0.07)),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const HwReportShimmer();
                  }
                  return RefreshIndicator(
                    color: _kBlue,
                    onRefresh: ctrl.reload,
                    child: Obx(() {
                      final list = ctrl.displayedHomework;

                      if (list.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [SizedBox(height: 80.h), const _EmptyState()],
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        itemCount: list.length + 2,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return _FadeSlideIn(
                              delay: const Duration(milliseconds: 380),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SummaryCard(ctrl: ctrl),
                                  SizedBox(height: 16.h),
                                  _SectionLabel(
                                    label:
                                        '${ctrl.selectedDateFilter.value == 3 ? 'hw_today_section'.tr : 'hw_section_class'.tr}  (${list.length})',
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            );
                          }
                          if (i == list.length + 1) {
                            return SizedBox(height: 20.h);
                          }
                          final idx = i - 1;
                          final delayMs = 440 + (idx * 65).clamp(0, 380);
                          return _FadeSlideIn(
                            delay: Duration(milliseconds: delayMs),
                            child: HwReportCard(
                              homework: list[i - 1],
                              ctrl: ctrl,
                            ),
                          );
                        },
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Staggered fade + slide + scale entry ─────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: ScaleTransition(scale: _scale, child: widget.child),
    ),
  );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.ctrl});

  final HomeworkTabController ctrl;

  static String _todayLabel() {
    final now = DateTime.now();
    return localizeDigits('${now.day} ${monthName(now.month)}');
  }

  void _showDateSheet(BuildContext context) {
    final options = [
      ('hw_filter_today'.tr, 3),
      ('hw_filter_week'.tr, 0),
      ('hw_filter_month'.tr, 1),
      ('hw_filter_all'.tr, 2),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        title: 'teacherhom36_filter_by_date'.tr,
        options: options
            .map(
              (o) => _SheetItem(
                label: o.$1,
                isSelected: ctrl.selectedDateFilter.value == o.$2,
                onTap: () {
                  ctrl.selectDateFilter(o.$2);
                  Get.back();
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _showClassSheet(BuildContext context) {
    final classrooms = ctrl.classrooms.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        title: 'teacherhom36_choose_class'.tr,
        options: [
          _SheetItem(
            label: 'hw_all_classes'.tr,
            isSelected: ctrl.selectedClassroomId.value == 'all',
            onTap: () {
              ctrl.selectClassroom('all');
              Get.back();
            },
          ),
          ...classrooms.map(
            (c) => _SheetItem(
              label: c.name ?? '',
              isSelected: ctrl.selectedClassroomId.value == c.key,
              onTap: () {
                ctrl.selectClassroom(c.key ?? '');
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectSheet(BuildContext context) {
    final subjects = ctrl.availableSubjectNames.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        title: 'teacherhom36_choose_subject'.tr,
        options: [
          _SheetItem(
            label: 'hw_all_subjects'.tr,
            isSelected: ctrl.selectedSubjectName.value == 'all',
            onTap: () {
              ctrl.selectSubject('all');
              Get.back();
            },
          ),
          ...subjects.map(
            (s) => _SheetItem(
              label: s,
              isSelected: ctrl.selectedSubjectName.value == s,
              onTap: () {
                ctrl.selectSubject(s);
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row + date badge
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'hw_tab_title'.tr,
                    style: context.typography.lgBold.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  _DateBadge(label: _todayLabel()),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () => Get.to(() => const StaffAccountView()),
                    child: Container(
                      width: 38.w,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: _kBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _kBlue.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 19.sp,
                        color: _kBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Single compact row: 3 dropdown chips
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Obx(() {
                final dateIdx = ctrl.selectedDateFilter.value;
                final classId = ctrl.selectedClassroomId.value;
                final subjectName = ctrl.selectedSubjectName.value;
                final classrooms = ctrl.classrooms.toList();
                final subjects = ctrl.availableSubjectNames.toList();
                ctrl.refreshToken;

                final dateLabel = switch (dateIdx) {
                  0 => 'hw_filter_week'.tr,
                  1 => 'hw_filter_month'.tr,
                  3 => 'hw_filter_today'.tr,
                  _ => 'hw_filter_all'.tr,
                };

                final cls = classrooms
                    .where((c) => c.key == classId)
                    .firstOrNull;
                final classLabel = classId == 'all'
                    ? 'hw_all_classes'.tr
                    : (cls?.name ?? 'hw_all_classes'.tr);

                final subjectLabel = subjectName == 'all'
                    ? 'hw_all_subjects'.tr
                    : subjectName;

                return Row(
                  children: [
                    _DropdownChip(
                      icon: Icons.calendar_today_rounded,
                      label: dateLabel,
                      isActive: dateIdx != 2,
                      onTap: () => _showDateSheet(context),
                    ),
                    SizedBox(width: 8.w),
                    _DropdownChip(
                      icon: Icons.school_rounded,
                      label: classLabel,
                      isActive: classId != 'all',
                      onTap: () => _showClassSheet(context),
                    ),
                    if (subjects.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      _DropdownChip(
                        icon: Icons.book_rounded,
                        label: subjectLabel,
                        isActive: subjectName != 'all',
                        onTap: () => _showSubjectSheet(context),
                      ),
                    ],
                  ],
                );
              }),
            ),
            Container(height: 1.h, color: const Color(0xFFE2E8F0)),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown chip ──────────────────────────────────────────────────────────────

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive
            ? _kBlue.withValues(alpha: 0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive
              ? _kBlue.withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: isActive ? _kBlue : const Color(0xFF64748B),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 12,
              color: isActive ? _kBlue : const Color(0xFF0F172A),
            ),
          ),
          SizedBox(width: 3.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 15.sp,
            color: isActive ? _kBlue : const Color(0xFF94A3B8),
          ),
        ],
      ),
    ),
  );
}

// ── Options bottom sheet ───────────────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({required this.title, required this.options});

  final String title;
  final List<_SheetItem> options;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    padding: EdgeInsets.fromLTRB(
      20.w,
      16.h,
      20.w,
      24.h + MediaQuery.of(context).padding.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: context.typography.displaySmBold.copyWith(
            fontSize: 15,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        ...options,
      ],
    ),
  );
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10.r),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.typography.smMedium.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _kBlue : const Color(0xFF374151),
              ),
            ),
          ),
          if (isSelected)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: const BoxDecoration(
                color: _kBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 12.sp,
                color: Colors.white,
              ),
            ),
        ],
      ),
    ),
  );
}

// ── Date badge ─────────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_rounded, size: 12.sp, color: _kBlue),
        SizedBox(width: 5.w),
        Text(
          label,
          style: context.typography.smSemiBold.copyWith(
            fontSize: 12,
            color: _kBlue,
          ),
        ),
      ],
    ),
  );
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.ctrl});

  final HomeworkTabController ctrl;

  @override
  Widget build(BuildContext context) => Obx(() {
    final total = ctrl.overallTotal;
    final assigned = ctrl.overallAssigned;
    final submitted = ctrl.overallSubmitted;
    final awaiting = ctrl.overallAwaiting;
    final reviewed = ctrl.overallReviewed;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                '$total ${'hw_stat_total'.tr}',
                style: context.typography.lgBold.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _SummaryStat(
                value: assigned,
                label: 'hw_sum_assigned'.tr,
                icon: Icons.groups_rounded,
              ),
              _SummaryDivider(),
              _SummaryStat(
                value: submitted,
                label: 'hw_sum_submitted'.tr,
                icon: Icons.home_rounded,
              ),
              _SummaryDivider(),
              _SummaryStat(
                value: awaiting,
                label: 'hw_sum_awaiting'.tr,
                icon: Icons.hourglass_bottom_rounded,
              ),
              _SummaryDivider(),
              _SummaryStat(
                value: reviewed,
                label: 'hw_sum_reviewed'.tr,
                icon: Icons.rate_review_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  });
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 16.sp, color: Colors.white.withValues(alpha: 0.85)),
        SizedBox(height: 6.h),
        Text(
          '$value',
          style: context.typography.mdBold.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.xsMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1.w,
    height: 34.h,
    color: Colors.white.withValues(alpha: 0.18),
  );
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.typography.displaySmBold.copyWith(
      fontSize: 15,
      color: const Color(0xFF0F172A),
      letterSpacing: -0.2,
    ),
  );
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(26.w),
            decoration: BoxDecoration(
              color: _kBlue.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_rounded,
              size: 52.sp,
              color: _kBlue,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'hw_empty_title'.tr,
            style: context.typography.mdBold.copyWith(
              fontSize: 16,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'hw_empty_sub'.tr,
            style: context.typography.xsRegular.copyWith(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
