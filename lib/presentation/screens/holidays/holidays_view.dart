import 'package:flutter/cupertino.dart';
import '../../../index/index_main.dart';

// ── Palette ─────────────────────────────────────────────────────────────────
const _accent = Color(0xFF6C4DDB);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _faint = Color(0xFF94A3B8);
const _bg = Color(0xFFF6F7FB);
const _line = Color(0xFFE9EDF3);
const _amber = Color(0xFFD97706);

// DateTime.weekday: Mon=1 … Sun=7.
const _weekdayNames = <int, String>{
  6: 'السبت',
  7: 'الأحد',
  1: 'الاثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
};

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

class HolidaysView extends StatefulWidget {
  const HolidaysView({super.key});

  @override
  State<HolidaysView> createState() => _HolidaysViewState();
}

class _HolidaysViewState extends State<HolidaysView> {
  late final HolidaysController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => HolidaysController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: HomeAppBar(title: 'الإجازات', showFilterIcon: false),
        floatingActionButton: _GradientFab(onPressed: () => _showAdd(context)),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
            children: [
              _WeekendSection(controller: controller),
              SizedBox(height: 24.h),
              _SectionTitle('أيام الإجازة'),
              SizedBox(height: 12.h),
              _HolidaysList(controller: controller, onAdd: () => _showAdd(context)),
            ],
          );
        }),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final now = DateTime.now();
    DateTime picked = DateTime(now.year, now.month, now.day);
    final labelCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'تحديد يوم إجازة',
                  style: context.typography.mdBold.copyWith(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 200.h,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: picked,
                    minimumYear: now.year,
                    maximumYear: now.year + 2,
                    onDateTimeChanged: (d) => picked = d,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                  child: TextField(
                    controller: labelCtrl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اسم المناسبة (اختياري) — مثلاً عيد الفطر',
                      hintStyle: TextStyle(color: _faint, fontSize: 13),
                      filled: true,
                      fillColor: _bg,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.addHoliday(picked, label: labelCtrl.text);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'حفظ الإجازة',
                          style: context.typography.displaySmBold.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Weekly weekend selector ──────────────────────────────────────────────────

class _WeekendSection extends StatelessWidget {
  const _WeekendSection({required this.controller});
  final HolidaysController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('العطلة الأسبوعية'),
        SizedBox(height: 6.h),
        Text(
          'الأيام المختارة تتحسب إجازة كل أسبوع تلقائيًا',
          style: context.typography.xsRegular.copyWith(
            color: _muted,
            fontSize: 12.5,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final selected = controller.weekendDays;
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final entry in _weekdayNames.entries)
                _DayChip(
                  label: entry.value,
                  selected: selected.contains(entry.key),
                  onTap: () => controller.toggleWeekday(entry.key),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? _accent : _line,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _ink,
          ),
        ),
      ),
    );
  }
}

// ── Specific holiday dates list ──────────────────────────────────────────────

class _HolidaysList extends StatelessWidget {
  const _HolidaysList({required this.controller, required this.onAdd});
  final HolidaysController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.holidays;
      if (list.isEmpty) return _EmptyState(onAdd: onAdd);
      return Column(
        children: [
          for (final h in list) _HolidayCard(holiday: h, controller: controller),
        ],
      );
    });
  }
}

class _HolidayCard extends StatelessWidget {
  const _HolidayCard({required this.holiday, required this.controller});
  final HolidayModel holiday;
  final HolidaysController controller;

  @override
  Widget build(BuildContext context) {
    final past = controller.isPast(holiday);
    final d = holiday.dateTime;
    final dateStr = '${d.day} ${_arMonths[d.month - 1]} ${d.year}';
    final weekday = _weekdayNames[d.weekday] ?? '';
    final color = past ? _faint : _amber;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.event_busy_rounded, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.label.trim().isNotEmpty ? holiday.label : 'إجازة',
                  style: context.typography.displaySmBold.copyWith(
                    color: past ? _muted : _ink,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  '$weekday · $dateStr',
                  style: context.typography.xsRegular.copyWith(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(Icons.delete_outline_rounded,
                  size: 22.sp, color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: const Text('حذف الإجازة'),
          content: const Text('متأكد إنك عايز تشيل الإجازة دي؟'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('إلغاء',
                  style: context.typography.smRegular.copyWith(color: _muted)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.deleteHoliday(holiday);
              },
              child: Text('حذف',
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFFEF4444))),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 34.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.h,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_rounded,
                size: 34.sp, color: _accent),
          ),
          SizedBox(height: 16.h),
          Text(
            'مفيش إجازات محددة',
            style: context.typography.mdBold.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'اضغط زر الإضافة عشان تحدد يوم إجازة',
            textAlign: TextAlign.center,
            style: context.typography.xsRegular.copyWith(
              fontSize: 13,
              color: _faint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 17,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.35),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'إضافة إجازة',
              style: context.typography.displaySmBold.copyWith(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
