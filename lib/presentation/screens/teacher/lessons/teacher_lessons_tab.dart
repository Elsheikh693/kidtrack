import '../../../../index/index_main.dart';
import 'teacher_lessons_controller.dart';

class TeacherLessonsTab extends StatelessWidget {
  const TeacherLessonsTab({super.key});

  static const _amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TeacherLessonsController());
    return Obx(() {
          if (c.isLoading.value && c.topics.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _amber),
            );
          }
          return RefreshIndicator(
            color: _amber,
            onRefresh: c.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const KidTrackCollapsingHeader(
                  title: 'الدروس',
                  icon: Icons.menu_book_rounded,
                  accentColor: _amber,
                ),
                SliverToBoxAdapter(
                  child: _FiltersSection(c: c),
                ),
                if (c.topics.isEmpty && !c.isLoading.value)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          if (i == 0) return _ProgressHeader(c: c);
                          final topic = c.topics[i - 1];
                          final isDone =
                              c.progress[topic.key]?.isDone == true;
                          return _TopicTile(
                            title: topic.title,
                            description: topic.description,
                            order: topic.order,
                            isDone: isDone,
                            onToggle: () => c.toggleTopic(topic.key ?? ''),
                          );
                        },
                        childCount: c.topics.length + 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({required this.c});
  final TeacherLessonsController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.myClassrooms.isEmpty || c.mySubjects.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.myClassrooms.length > 1) ...[
             Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'الفصل',
                style: context.typography.xsMedium.copyWith(color: Color(0xFF6B7280)),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: c.myClassrooms.length,
                itemBuilder: (context, i) {
                  final cl = c.myClassrooms[i];
                  final selected = c.selectedClassroom.value?.key == cl.key;
                  return _FilterChip(
                    label: cl.name,
                    selected: selected,
                    color: const Color(0xFFD97706),
                    onTap: () => c.selectClassroom(cl),
                  );
                },
              ),
            ),
          ],
           Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'المادة',
              style: context.typography.xsMedium.copyWith(color: Color(0xFF6B7280)),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: c.mySubjects.length,
              itemBuilder: (context, i) {
                final s = c.mySubjects[i];
                final selected = c.selectedSubject.value?.key == s.key;
                return _FilterChip(
                  label: s.name,
                  selected: selected,
                  color: const Color(0xFF7C3AED),
                  onTap: () => c.selectSubject(s),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(color: selected ? Colors.white : const Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

// ── Progress Header ───────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.c});
  final TeacherLessonsController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final done = c.doneCount;
      final total = c.totalCount;
      if (total == 0) return const SizedBox();
      final ratio = total == 0 ? 0.0 : done / total;
      return Container(
        margin: const EdgeInsets.only(bottom: 16, top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD97706).withValues(alpha: 0.12),
              const Color(0xFFF59E0B).withValues(alpha: 0.06),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقدم في ${c.selectedSubject.value?.name ?? ""}',
                  style: context.typography.xsMedium.copyWith(color: Color(0xFF92400E)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$done / $total',
                    style: context.typography.xsMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD97706)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(ratio * 100).toInt()}% من المواضيع تم تغطيتها',
              style: context.typography.xsRegular.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    });
  }
}

// ── Topic Tile ────────────────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.title,
    required this.description,
    required this.order,
    required this.isDone,
    required this.onToggle,
  });
  final String title;
  final String? description;
  final int order;
  final bool isDone;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF16A34A).withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? const Color(0xFF16A34A).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF16A34A)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : Text(
                            '${order + 1}',
                            style: context.typography.xsMedium.copyWith(color: Colors.grey.shade500),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.typography.displaySmBold.copyWith(
                          color: isDone ? const Color(0xFF166534) : const Color(0xFF111827),
                          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationColor: const Color(0xFF16A34A),
                        ),
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(description!,
                            style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500)),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      isDone ? const Color(0xFF16A34A) : Colors.grey.shade300,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 56, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواضيع لهذه المادة',
              style: context.typography.mdBold.copyWith(color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 8),
            Text(
              'تواصلي مع المدير لإضافة مواضيع المنهج',
              textAlign: TextAlign.center,
              style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
