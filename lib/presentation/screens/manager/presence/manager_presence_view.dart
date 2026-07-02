import '../../../../index/index_main.dart';
import '../children/models/presence_entry.dart';

/// Full-day attendance movement for the Branch Manager: a date picker, a
/// present / inside / left summary, and the per-child arrival & pickup times.
class ManagerPresenceView extends StatelessWidget {
  const ManagerPresenceView({super.key});

  static const _insideColor = AppColors.activityGreen;
  static const _leftColor = AppColors.activityAmberBrand;
  static const _bg = Color(0xFFF6F8FB);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagerPresenceController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            'manager_presence_title'.tr,
            style: context.typography.mdBold.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textDefault,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.sp, color: AppColors.textDefault),
            onPressed: Get.back,
          ),
        ),
        body: Obx(() {
          return RefreshIndicator(
            onRefresh: controller.loadData,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Column(
                      children: [
                        _DateBar(controller: controller),
                        SizedBox(height: 14.h),
                        _SummaryCard(controller: controller),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading.value)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _Empty(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final e = controller.entries[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _MovementRow(
                              entry: e,
                              insideColor: _insideColor,
                              leftColor: _leftColor,
                              onTap: () => controller.openChild(e.childId),
                            ),
                          );
                        },
                        childCount: controller.entries.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({required this.controller});

  final ManagerPresenceController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavArrow(icon: Icons.chevron_right_rounded, onTap: controller.goPreviousDay),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            onTap: controller.pickDate,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10.r,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      arabicFullDate(controller.selectedDate.value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                  ),
                  if (controller.isToday) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'manager_presence_today'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        _NavArrow(
          icon: Icons.chevron_left_rounded,
          onTap: controller.isToday ? null : controller.goNextDay,
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22.sp,
          color: enabled ? AppColors.textDefault : AppColors.grayLight,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});

  final ManagerPresenceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _Stat(
            value: '${controller.totalAttended}',
            label: 'manager_presence_stat_attended'.tr,
            color: AppColors.primary,
          ),
          _Divider(),
          _Stat(
            value: '${controller.insideCount}',
            label: 'manager_presence_stat_inside'.tr,
            color: AppColors.activityGreen,
          ),
          _Divider(),
          _Stat(
            value: '${controller.leftCount}',
            label: 'manager_presence_stat_left'.tr,
            color: AppColors.activityAmberBrand,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: context.typography.xlBold.copyWith(color: color),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34.h,
      color: AppColors.dividerAndLines.withValues(alpha: 0.7),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.entry,
    required this.insideColor,
    required this.leftColor,
    required this.onTap,
  });

  final PresenceEntry entry;
  final Color insideColor;
  final Color leftColor;
  final VoidCallback onTap;

  String get _initial {
    final t = entry.name.trim();
    return t.isEmpty ? '؟' : t.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final accent = entry.isInside ? insideColor : leftColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                _initial,
                style: context.typography.smSemiBold.copyWith(color: accent),
              ),
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
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      _TimePill(
                        icon: Icons.login_rounded,
                        color: insideColor,
                        text: entry.checkInMs != null
                            ? arabicClockTime(entry.checkInMs!)
                            : '—',
                      ),
                      SizedBox(width: 8.w),
                      if (entry.checkOutMs != null)
                        _TimePill(
                          icon: Icons.logout_rounded,
                          color: leftColor,
                          text: arabicClockTime(entry.checkOutMs!),
                        )
                      else
                        _StillInsidePill(color: insideColor),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              entry.classroomName,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            text,
            style: context.typography.xsRegular.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StillInsidePill extends StatelessWidget {
  const _StillInsidePill({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            'manager_presence_still_inside'.tr,
            style: context.typography.xsRegular
                .copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 56.sp, color: AppColors.grayLight),
          SizedBox(height: 12.h),
          Text(
            'manager_presence_empty'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
