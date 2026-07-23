import '../../../../index/index_main.dart';
import 'widgets/pickup_persons_sheet.dart';

class ReceptionistCheckInView extends StatefulWidget {
  const ReceptionistCheckInView({super.key});

  @override
  State<ReceptionistCheckInView> createState() =>
      _ReceptionistCheckInViewState();
}

class _ReceptionistCheckInViewState extends State<ReceptionistCheckInView> {
  late final ReceptionistCheckInController controller;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReceptionistCheckInController());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0891B2),
          foregroundColor: Colors.white,
          title: Text(
            'تسجيل الحضور',
            style: context.typography.mdBold,
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () => Get.toNamed(settingsView),
            ),
            SizedBox(width: 6.w),
          ],
        ),
        body: Obx(() {
          final loading = controller.isLoading.value;
          final items = controller.children;
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _SummaryBar(controller: controller)),
              SliverToBoxAdapter(
                child: _SearchAndFilter(controller: controller, search: _search),
              ),
              if (loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyList(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) =>
                          _CheckInCard(entry: items[i], controller: controller),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.controller});
  final ReceptionistCheckInController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trigger rebuild by reading children.
      controller.children.length;

      return Container(
        color: const Color(0xFF0891B2),
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Row(
          children: [
            _StatChip(
              label: 'الكل',
              count: controller.totalCount,
              color: Colors.white,
              bg: Colors.white.withValues(alpha: 0.2),
            ),
            SizedBox(width: 10.w),
            _StatChip(
              label: 'حاضر',
              count: controller.presentCount,
              color: const Color(0xFF34D399),
              bg: const Color(0xFF34D399).withValues(alpha: 0.15),
            ),
            SizedBox(width: 10.w),
            _StatChip(
              label: 'غائب',
              count: controller.absentCount,
              color: const Color(0xFFFCA5A5),
              bg: const Color(0xFFFCA5A5).withValues(alpha: 0.15),
            ),
          ],
        ),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  final String label;
  final int count;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            '$count',
            style: context.typography.mdBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Search + filter ───────────────────────────────────────────────────────────

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({required this.controller, required this.search});
  final ReceptionistCheckInController controller;
  final TextEditingController search;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: search,
            onChanged: controller.setSearch,
            decoration: InputDecoration(
              hintText: 'بحث عن طفل...',
              hintStyle: context.typography.smRegular
                  .copyWith(fontSize: 14, color: const Color(0xFF94A3B8)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: const Color(0xFF94A3B8), size: 20.sp),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Filter chips
          Obx(() {
            final f = controller.filterStatus.value;
            return Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: f == 'all',
                  onTap: () => controller.setFilter('all'),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'حاضر',
                  selected: f == 'present',
                  onTap: () => controller.setFilter('present'),
                  color: const Color(0xFF059669),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'غائب',
                  selected: f == 'absent',
                  onTap: () => controller.setFilter('absent'),
                  color: const Color(0xFFDC2626),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF0891B2);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? c : c.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(color: selected ? Colors.white : c),
        ),
      ),
    );
  }
}

// ── Child list ────────────────────────────────────────────────────────────────

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.child_care_rounded,
              size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'لا يوجد أطفال',
            style: context.typography.displaySmBold
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

// ── Card per child ────────────────────────────────────────────────────────────

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.entry, required this.controller});
  final CheckInChildEntry entry;
  final ReceptionistCheckInController controller;

  @override
  Widget build(BuildContext context) {
    final child = entry.child;
    final isPresent = entry.isPresent;
    final isCheckedOutToday = entry.isCheckedOutToday;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isPresent
            ? Border.all(
                color: entry.statusColor.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            ChildAvatar(
              name: child.fullName,
              imageUrl: child.profileImage,
              size: 48.w,
              color: entry.statusColor,
            ),
            SizedBox(width: 12.w),

            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: context.typography.displaySmBold.copyWith(color: const Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(entry.statusIcon,
                          size: 13.sp, color: entry.statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        entry.statusLabel,
                        style: context.typography.xsMedium.copyWith(color: entry.statusColor),
                      ),
                      if (entry.currentStatus?.checkInTime != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '• ${_fmtTime(entry.currentStatus!.checkInTime!)}',
                          style: context.typography.xsRegular.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ],
                  ),
                  _PickupChip(child: child, controller: controller),
                ],
              ),
            ),

            // Action button
            if (isPresent)
              _OutBtn(onTap: () => controller.checkOut(entry))
            else if (!isCheckedOutToday)
              _InBtn(onTap: () => controller.checkIn(entry)),
            // isCheckedOutToday → no button, flow is done for today
          ],
        ),
      ),
    );
  }

  static String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Tappable badge showing how many people are authorized to pick this child up.
/// Hidden entirely when none are registered. Opens the read-only persons sheet.
class _PickupChip extends StatelessWidget {
  const _PickupChip({required this.child, required this.controller});
  final ChildModel child;
  final ReceptionistCheckInController controller;

  @override
  Widget build(BuildContext context) {
    final persons = controller.pickupsFor(child.key);
    if (persons.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: GestureDetector(
        onTap: () => showPickupPersonsSheet(child, persons),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.how_to_reg_rounded,
                  size: 13.sp, color: const Color(0xFFD97706)),
              SizedBox(width: 4.w),
              Text(
                '${'pickup_authorized_short'.tr} (${persons.length})',
                style: context.typography.xsMedium
                    .copyWith(fontSize: 12, color: const Color(0xFFD97706)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InBtn extends StatelessWidget {
  const _InBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login_rounded, size: 15.sp, color: Colors.white),
            SizedBox(width: 5.w),
            Text(
              'حضر',
              style: context.typography.xsMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutBtn extends StatelessWidget {
  const _OutBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 15.sp, color: const Color(0xFFDC2626)),
            SizedBox(width: 5.w),
            Text(
              'خروج',
              style: context.typography.xsMedium.copyWith(color: Color(0xFFDC2626)),
            ),
          ],
        ),
      ),
    );
  }
}

