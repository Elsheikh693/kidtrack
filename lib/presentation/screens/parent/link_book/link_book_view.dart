import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Domain/UseCases/use_case.dart';
import '../education/widgets/journal_meta.dart';
import 'link_book_controller.dart';
import 'link_book_day_view.dart';
import 'subject_history_view.dart';
import 'widgets/link_book_day_card.dart';
import 'widgets/subject_history_card.dart';

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kJBg,
        appBar: AppBar(
          backgroundColor: kJBg,
          surfaceTintColor: kJBg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'دفتر التواصل',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: kJInk,
            ),
          ),
          iconTheme: const IconThemeData(color: kJInk),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final days = controller.days;
          if (days.isEmpty) return const _Empty();

          final mode = controller.viewMode.value;

          return RefreshIndicator(
            onRefresh: controller.reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: _Intro(
                    childName: controller.childName,
                    dayCount: days.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ModeToggle(
                    mode: mode,
                    onSelect: controller.setMode,
                  ),
                ),
                if (mode == LbViewMode.days)
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
    final months = controller.months;
    final filtered = controller.filteredDays;
    return [
      if (months.length > 1)
        SliverToBoxAdapter(
          child: _MonthBar(
            months: months,
            selected: controller.selectedMonth.value,
            onSelect: controller.setMonth,
          ),
        ),
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
              final day = filtered[i];
              return LinkBookDayCard(
                day: day,
                onTap: () => Get.to(() => LinkBookDayView(
                      day: day,
                      childName: controller.childName,
                    )),
              );
            },
            childCount: filtered.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _subjectsSlivers(BuildContext context) {
    final subjects = controller.subjectHistories;
    if (subjects.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _SubjectsEmpty(),
        ),
      ];
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
              label: 'الأيام',
              selected: mode == LbViewMode.days,
              onTap: () => onSelect(LbViewMode.days),
            ),
          ),
          Expanded(
            child: _ModeTab(
              icon: Icons.category_rounded,
              label: 'المواد',
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
            const Text(
              'لا توجد مواد بعد',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'هتظهر المواد هنا أول ما تبدأ أنشطة طفلك.',
              textAlign: TextAlign.center,
              style: TextStyle(
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

const _kArMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String _monthLabel(DateTime m) {
  final now = DateTime.now();
  final base = _kArMonths[m.month - 1];
  return m.year == now.year ? base : '$base ${m.year}';
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.months,
    required this.selected,
    required this.onSelect,
  });

  final List<DateTime> months;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelect;

  bool _isSel(DateTime m) =>
      selected != null && selected!.year == m.year && selected!.month == m.month;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _Chip(
            label: 'الكل',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final m in months) ...[
            const SizedBox(width: 8),
            _Chip(
              label: _monthLabel(m),
              selected: _isSel(m),
              onTap: () => onSelect(m),
            ),
          ],
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

class _Intro extends StatelessWidget {
  const _Intro({required this.childName, required this.dayCount});
  final String childName;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C4DDB), Color(0xFF8B5CF6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C4DDB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دفتر $childName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كل أيامه في مكان واحد · $dayCount يوم',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
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
            const Text(
              'الدفتر فاضي حاليًا',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لسه مفيش أيام مسجلة لطفلك.\nهتظهر هنا أول ما تبدأ الأنشطة.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
