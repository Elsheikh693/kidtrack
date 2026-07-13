import '../../../../../index/index_main.dart';
import '../../children/models/presence_entry.dart';

/// Live "who is in the nursery right now" breakdown for the manager home. Drills
/// the attendance ring above into the actual children: a toggle between those
/// still on-site and those already picked up. Renders nothing until the day has
/// any attendance, so an empty pre-arrival morning stays clean.
class DashboardPresenceCard extends StatefulWidget {
  const DashboardPresenceCard({super.key, required this.controller});

  final ManagerDashboardController controller;

  static const previewCount = 3;

  @override
  State<DashboardPresenceCard> createState() => _DashboardPresenceCardState();
}

class _DashboardPresenceCardState extends State<DashboardPresenceCard> {
  static const _insideColor = AppColors.activityGreen;
  static const _leftColor = AppColors.activityAmberBrand;

  // 0 = inside now, 1 = left today.
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = widget.controller;
      if (!c.hasAttendanceToday) return const SizedBox.shrink();

      final inside = c.insideNow;
      final left = c.leftToday;
      // Keep the toggle on a meaningful tab as numbers shift through the day.
      if (_segment == 1 && left.isEmpty) _segment = 0;
      final showingInside = _segment == 0;
      final list = showingInside ? inside : left;
      final accent = showingInside ? _insideColor : _leftColor;
      final preview = list.take(DashboardPresenceCard.previewCount).toList();

      return Container(
        margin: EdgeInsets.only(bottom: 22.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(accent: accent),
                  SizedBox(height: 14.h),
                  _SegmentBar(
                    selected: _segment,
                    insideCount: inside.length,
                    leftCount: left.length,
                    insideColor: _insideColor,
                    leftColor: _leftColor,
                    onSelect: (i) => setState(() => _segment = i),
                  ),
                ],
              ),
            ),
            if (preview.isEmpty)
              _Empty(showingInside: showingInside)
            else
              ...List.generate(preview.length, (i) {
                return _PresenceRow(
                  entry: preview[i],
                  accent: accent,
                  showingInside: showingInside,
                  showDivider: i != preview.length - 1,
                  onTap: () => c.openChild(preview[i].childId),
                );
              }),
            _ViewAllButton(
              extra: list.length - preview.length,
              onTap: () => Get.toNamed(managerPresenceView),
            ),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.meeting_room_rounded, color: accent, size: 19.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'manager_dashboard_presence_title'.tr,
            style: context.typography.mdBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.selected,
    required this.insideCount,
    required this.leftCount,
    required this.insideColor,
    required this.leftColor,
    required this.onSelect,
  });

  final int selected;
  final int insideCount;
  final int leftCount;
  final Color insideColor;
  final Color leftColor;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.grayLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _SegmentTab(
            label: 'manager_dashboard_presence_inside'.tr,
            count: insideCount,
            color: insideColor,
            active: selected == 0,
            onTap: () => onSelect(0),
          ),
          SizedBox(width: 4.w),
          _SegmentTab(
            label: 'manager_dashboard_presence_left'.tr,
            count: leftCount,
            color: leftColor,
            active: selected == 1,
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(
                  color: active
                      ? AppColors.textDefault
                      : AppColors.textSecondaryParagraph,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                '$count',
                style: context.typography.xsRegular.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: active ? color : AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.extra, required this.onTap});

  /// How many more rows exist beyond the preview (0 when all are shown).
  final int extra;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = extra > 0
        ? 'manager_dashboard_presence_view_all_more'.trParams({'n': '$extra'})
        : 'manager_dashboard_presence_view_all'.tr;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.dividerAndLines.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: context.typography.smSemiBold.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresenceRow extends StatelessWidget {
  const _PresenceRow({
    required this.entry,
    required this.accent,
    required this.showingInside,
    required this.showDivider,
    required this.onTap,
  });

  final PresenceEntry entry;
  final Color accent;
  final bool showingInside;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeMs = showingInside ? entry.checkInMs : entry.checkOutMs;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.dividerAndLines.withValues(alpha: 0.6),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            ChildAvatar(
              name: entry.name,
              imageUrl: entry.imageUrl,
              size: 38.w,
              color: accent,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smSemiBold.copyWith(
                      color: AppColors.textDefault,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    entry.classroomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            _TimeChip(
              ms: timeMs,
              accent: accent,
              icon: showingInside ? Icons.login_rounded : Icons.logout_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.ms, required this.accent, required this.icon});

  final int? ms;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (ms == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            arabicClockTime(ms!),
            style: context.typography.xsRegular.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5.sp,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.showingInside});

  final bool showingInside;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
      child: Row(
        children: [
          Icon(
            showingInside ? Icons.nights_stay_rounded : Icons.schedule_rounded,
            color: AppColors.textSecondaryParagraph,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              (showingInside
                      ? 'manager_dashboard_presence_inside_empty'
                      : 'manager_dashboard_presence_left_empty')
                  .tr,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
