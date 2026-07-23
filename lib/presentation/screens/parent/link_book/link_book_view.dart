import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Domain/UseCases/use_case.dart';
import '../education/widgets/journal_meta.dart';
import '../exams/parent_exams_view.dart';
import 'link_book_controller.dart';
import 'link_book_day_view.dart';
import 'subject_history_view.dart';
import 'widgets/link_book_day_card.dart';
import 'widgets/subject_history_card.dart';
import '../../../../Global/Localization/app_direction.dart';
import '../../../../Global/Utils/date_helpers.dart';

/// The full Link Book: every day of the child as a browsable grid of pages.
class LinkBookView extends StatefulWidget {
  const LinkBookView({super.key});

  @override
  State<LinkBookView> createState() => _LinkBookViewState();
}

class _LinkBookViewState extends State<LinkBookView> {
  late final ParentLinkBookController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentLinkBookController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: kJBg,
        appBar: AppBar(
          backgroundColor: kJBg,
          surfaceTintColor: kJBg,
          elevation: 0,
          centerTitle: true,
          title: Obx(() {
            final count = controller.days.length;
            final showSub = !controller.isLoading.value && count > 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'parentlink25_link_book_title'.tr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kJInk,
                  ),
                ),
                if (showSub) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${controller.childName} · $count ${'parentlink25_day_unit'.tr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: kJMuted,
                    ),
                  ),
                ],
              ],
            );
          }),
          iconTheme: const IconThemeData(color: kJInk),
          actions: [
            IconButton(
              tooltip: 'exams_title'.tr,
              onPressed: () => Get.to(() => const ParentExamsView()),
              icon: const Icon(Icons.assignment_rounded, color: Color(0xFF6C4DDB)),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          // No history at all (child never had a recorded day).
          if (controller.availableMonths.isEmpty) return const _Empty();

          final mode = controller.viewMode.value;
          final months = controller.availableMonths;

          return RefreshIndicator(
            onRefresh: controller.reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: _ModeToggle(
                    mode: mode,
                    onSelect: controller.setMode,
                  ),
                ),
                // Month picker governs BOTH tabs — data is loaded one month at
                // a time so the book scales to years without a giant fetch.
                if (months.length > 1)
                  SliverToBoxAdapter(
                    child: _MonthBar(
                      months: months,
                      selected: controller.selectedMonth.value!,
                      onSelect: controller.setMonth,
                    ),
                  ),
                if (controller.daysLoading.value)
                  const SliverToBoxAdapter(child: _MonthLoading())
                else if (mode == LbViewMode.days)
                  ..._daysSlivers(context)
                else
                  ..._subjectsSlivers(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _daysSlivers(BuildContext context) {
    final days = controller.days;
    if (days.isEmpty) {
      return const [SliverToBoxAdapter(child: _MonthEmpty())];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 168,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final day = days[i];
              return LinkBookDayCard(
                day: day,
                onTap: () => Get.to(() => LinkBookDayView(
                      day: day,
                      childName: controller.childName,
                    )),
              );
            },
            childCount: days.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _subjectsSlivers(BuildContext context) {
    final subjects = controller.subjectHistories;
    if (subjects.isEmpty) {
      return const [SliverToBoxAdapter(child: _SubjectsEmpty())];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final s = subjects[i];
              return SubjectHistoryCard(
                subject: s,
                onTap: () => Get.to(() => SubjectHistoryView(
                      subject: s,
                      childName: controller.childName,
                    )),
              );
            },
            childCount: subjects.length,
          ),
        ),
      ),
    ];
  }
}

/// Segmented toggle: browse the book by day, or by subject.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onSelect});
  final LbViewMode mode;
  final ValueChanged<LbViewMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kJBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTab(
              icon: Icons.calendar_today_rounded,
              label: 'parentlink25_tab_days'.tr,
              selected: mode == LbViewMode.days,
              onTap: () => onSelect(LbViewMode.days),
            ),
          ),
          Expanded(
            child: _ModeTab(
              icon: Icons.category_rounded,
              label: 'parentlink25_tab_subjects'.tr,
              selected: mode == LbViewMode.subjects,
              onTap: () => onSelect(LbViewMode.subjects),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _accent = Color(0xFF6C4DDB);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : kJMuted,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : kJMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectsEmpty extends StatelessWidget {
  const _SubjectsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4DDB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.category_rounded,
                  size: 36, color: Color(0xFF6C4DDB)),
            ),
            const SizedBox(height: 16),
            Text(
              'parentlink25_no_subjects_title'.tr,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'parentlink25_no_subjects_desc'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: kJMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthLabel(DateTime m) {
  final now = DateTime.now();
  final base = monthName(m.month);
  return m.year == now.year ? base : '$base ${m.year}';
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.months,
    required this.selected,
    required this.onSelect,
  });

  final List<DateTime> months;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  bool _isSel(DateTime m) =>
      selected.year == m.year && selected.month == m.month;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          for (var i = 0; i < months.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Chip(
              label: _monthLabel(months[i]),
              selected: _isSel(months[i]),
              onTap: () => onSelect(months[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loader shown while a month is being fetched (keeps the month bar up).
class _MonthLoading extends StatelessWidget {
  const _MonthLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Shown when the selected month has no recorded days.
class _MonthEmpty extends StatelessWidget {
  const _MonthEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6C4DDB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.event_busy_rounded,
                size: 32, color: Color(0xFF6C4DDB)),
          ),
          const SizedBox(height: 14),
          Text(
            'parentlink25_no_days_month_title'.tr,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: kJInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'parentlink25_no_days_month_desc'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: kJMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _accent = Color(0xFF6C4DDB);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _accent : kJBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : kJMuted,
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4DDB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 44, color: Color(0xFF6C4DDB)),
            ),
            const SizedBox(height: 18),
            Text(
              'parentlink25_empty_title'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'parentlink25_empty_desc'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: kJMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
