import '../../../../index/index_main.dart';
import '../../../../Data/models/child/child_model.dart';
import '../../../../Data/models/daily_assessment/daily_assessment_model.dart';
import '../../../../Global/widgets/app_network_image.dart';
import 'teacher_assessment_controller.dart';

class TeacherAssessmentTab extends StatelessWidget {
  const TeacherAssessmentTab({super.key});

  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TeacherAssessmentController());
    return Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: Obx(() {
          if (c.isLoading.value && c.children.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _purple),
            );
          }
          return RefreshIndicator(
            color: _purple,
            onRefresh: c.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _ClassroomSelector(c: c),
                ),
                SliverToBoxAdapter(
                  child: _TodayBanner(c: c),
                ),
                if (c.children.isEmpty && !c.isLoading.value)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final child = c.children[i];
                          return _ChildAssessmentCard(c: c, child: child);
                        },
                        childCount: c.children.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        floatingActionButton: Obx(() => c.children.isEmpty
            ? const SizedBox()
            : _SaveButton(c: c)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
  }
}

// ── Classroom Selector ────────────────────────────────────────────────────────

class _ClassroomSelector extends StatelessWidget {
  const _ClassroomSelector({required this.c});
  final TeacherAssessmentController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.myClassrooms.length <= 1) return const SizedBox();
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: c.myClassrooms.length,
          itemBuilder: (ctx, i) {
            final cl = c.myClassrooms[i];
            final selected = c.selectedClassroom.value?.key == cl.key;
            return GestureDetector(
              onTap: () => c.selectClassroom(cl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF7C3AED)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF7C3AED)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  cl.name,
                  style: context.typography.xsMedium.copyWith(color: selected ? Colors.white : const Color(0xFF6B7280)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Today Banner ──────────────────────────────────────────────────────────────

class _TodayBanner extends StatelessWidget {
  const _TodayBanner({required this.c});
  final TeacherAssessmentController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.children.isEmpty) return const SizedBox();
      final total = c.children.length;
      final assessed = c.existing.length;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C3AED).withValues(alpha: 0.1),
              const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.today_rounded,
                color: Color(0xFF7C3AED), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تقييمات اليوم — ${c.selectedClassroom.value?.name ?? ""}',
                style: context.typography.xsMedium.copyWith(color: const Color(0xFF4C1D95)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: assessed == total && total > 0
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$assessed / $total',
                style: context.typography.xsMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Child Assessment Card ─────────────────────────────────────────────────────

class _ChildAssessmentCard extends StatelessWidget {
  const _ChildAssessmentCard({
    required this.c,
    required this.child,
  });
  final TeacherAssessmentController c;
  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final id = child.key ?? '';
    return Obx(() {
      final rating = c.ratings[id] ?? DailyRating.good;
      final isSaved = c.existing.containsKey(id);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSaved
                ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Child header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  _Avatar(child: child),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          style: context.typography.displaySmBold.copyWith(color: const Color(0xFF111827)),
                        ),
                        if (isSaved)
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 12,
                                  color: Colors.green.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'تم التقييم',
                                style: context.typography.xsMedium.copyWith(color: Colors.green.shade600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Current rating badge
                  _RatingBadge(rating: rating),
                ],
              ),
            ),
            // ── Rating buttons ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: DailyRating.values.map((r) {
                  final selected = rating == r;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _RatingButton(
                        rating: r,
                        selected: selected,
                        onTap: () => c.setRating(id, r),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // ── Comment field (visible when needsSupport) ──────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: rating == DailyRating.needsSupport
                  ? _CommentField(
                      initialValue: c.comments[id] ?? '',
                      onChanged: (v) => c.setComment(id, v),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    });
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.child});
  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
      ),
      child: child.profileImage != null && child.profileImage!.isNotEmpty
          ? ClipOval(
              child: AppNetworkImage(
                url: child.profileImage!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Text(
                child.fullName.isNotEmpty ? child.fullName[0] : '?',
                style: context.typography.lgBold.copyWith(color: const Color(0xFF7C3AED)),
              ),
            ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final DailyRating rating;

  static const _colors = {
    DailyRating.excellent: Color(0xFF16A34A),
    DailyRating.veryGood: Color(0xFF0891B2),
    DailyRating.good: Color(0xFFD97706),
    DailyRating.needsSupport: Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[rating] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        rating.emoji,
        style: context.typography.smMedium,
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.rating,
    required this.selected,
    required this.onTap,
  });
  final DailyRating rating;
  final bool selected;
  final VoidCallback onTap;

  static const _colors = {
    DailyRating.excellent: Color(0xFF16A34A),
    DailyRating.veryGood: Color(0xFF0891B2),
    DailyRating.good: Color(0xFFD97706),
    DailyRating.needsSupport: Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[rating] ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rating.emoji, style: context.typography.smMedium),
            const SizedBox(height: 2),
            Text(
              _shortLabel(rating),
              style: context.typography.xsMedium.copyWith(color: selected ? Colors.white : color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(DailyRating r) {
    switch (r) {
      case DailyRating.excellent:    return 'ممتاز';
      case DailyRating.veryGood:     return 'جيد جداً';
      case DailyRating.good:         return 'جيد';
      case DailyRating.needsSupport: return 'يحتاج\nمتابعة';
    }
  }
}

class _CommentField extends StatefulWidget {
  const _CommentField({required this.initialValue, required this.onChanged});
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<_CommentField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'ملاحظة على الطالب (اختياري)...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.edit_note_rounded,
              color: Colors.grey.shade400, size: 20),
          filled: true,
          fillColor: const Color(0xFFFFF7F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFDC2626), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

// ── Save FAB ──────────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.c});
  final TeacherAssessmentController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: c.isSaving.value ? null : c.saveAll,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor:
                    const Color(0xFF7C3AED).withValues(alpha: 0.4),
              ),
              child: c.isSaving.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'حفظ تقييمات ${c.children.length} طالب',
                          style: context.typography.mdBold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ));
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
            Icon(Icons.groups_rounded, size: 56, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلاب في هذا الفصل',
              style: context.typography.mdBold.copyWith(color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
