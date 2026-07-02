import '../../../../index/index_main.dart';

class TeacherClassesTab extends StatefulWidget {
  const TeacherClassesTab({super.key});

  @override
  State<TeacherClassesTab> createState() => _TeacherClassesTabState();
}

class _TeacherClassesTabState extends State<TeacherClassesTab> {
  late final TeacherClassesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => TeacherClassesController());
  }

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: _green),
              );
            }
            return RefreshIndicator(
              color: _green,
              onRefresh: controller.refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  if (controller.myClassrooms.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _ClassroomCard(
                          classroom: controller.myClassrooms[i],
                          controller: controller,
                        ),
                        childCount: controller.myClassrooms.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فصولي',
                      style: context.typography.xlBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'نظرة عامة على فصولك الدراسية',
                      style: context.typography.xsRegular.copyWith(
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.myClassrooms.length} فصل',
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final total = controller.childCounts.values.fold(
              0,
              (s, v) => s + v,
            );
            final assessed = controller.todayAssessedCounts.values.fold(
              0,
              (s, v) => s + v,
            );
            return Row(
              children: [
                _StatChip(icon: Icons.child_care_rounded, label: '$total طفل'),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.star_rounded,
                  label: 'قُيِّم اليوم: $assessed',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم تعيين فصول لك بعد',
              style: context.typography.mdBold.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تواصلي مع مدير الحضانة لتعيين فصولك',
              textAlign: TextAlign.center,
              style: context.typography.xsRegular.copyWith(
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Classroom Card ─────────────────────────────────────────────────────────────

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({required this.classroom, required this.controller});

  final ClassroomModel classroom;
  final TeacherClassesController controller;

  static const _green = Color(0xFF16A34A);
  static const _purple = Color(0xFF7C3AED);
  static const _amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final cId = classroom.key ?? '';

    return Obx(() {
      final subjects = controller.subjectsForClassroom(cId);
      final childCount = controller.childCounts[cId] ?? 0;
      final assessedCount = controller.todayAssessedCounts[cId] ?? 0;
      final assessmentDone = childCount > 0 && assessedCount >= childCount;
      final assessmentProgress = childCount > 0
          ? assessedCount / childCount
          : 0.0;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.meeting_room_rounded,
                      color: _green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.name,
                          style: context.typography.mdBold.copyWith(
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$childCount طفل',
                          style: context.typography.xsRegular.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Assessment badge
                  _AssessmentBadge(
                    assessed: assessedCount,
                    total: childCount,
                    isDone: assessmentDone,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subjects
                  if (subjects.isNotEmpty) ...[
                    Text(
                      'المواد الدراسية',
                      style: context.typography.xsMedium.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: subjects
                          .map((s) => _SubjectChip(subject: s))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Assessment progress bar
                  if (childCount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقييم اليومي',
                          style: context.typography.xsMedium.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '$assessedCount / $childCount',
                          style: context.typography.xsMedium.copyWith(
                            color: assessmentDone
                                ? _green
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: assessmentProgress,
                        backgroundColor: Colors.grey.shade100,
                        color: assessmentDone ? _green : _amber,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),

            // Quick action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.menu_book_rounded,
                      label: 'الدروس',
                      color: _amber,
                      onTap: () => _goToLessons(context, cId, subjects),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.star_rounded,
                      label: 'التقييم',
                      color: _purple,
                      onTap: () => _goToAssessment(context, cId),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _goToLessons(
    BuildContext context,
    String cId,
    List<SubjectModel> subjects,
  ) {
    // Navigate to the Lessons tab (index 2 in teacher nav)
    final mainVm = Get.find<MainPageViewModel>();
    mainVm.changePage(2);
    // Pass preselected classroom to lessons controller if available
    // (The lessons controller will pick up changes when rebuilt)
  }

  void _goToAssessment(BuildContext context, String cId) {
    final mainVm = Get.find<MainPageViewModel>();
    mainVm.changePage(3);
  }
}

class _AssessmentBadge extends StatelessWidget {
  const _AssessmentBadge({
    required this.assessed,
    required this.total,
    required this.isDone,
  });

  final int assessed;
  final int total;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF16A34A).withValues(alpha: 0.1)
            : const Color(0xFFD97706).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 13,
            color: isDone ? const Color(0xFF16A34A) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 4),
          Text(
            isDone ? 'مكتمل' : '$assessed/$total',
            style: context.typography.xsMedium.copyWith(
              color: isDone ? const Color(0xFF166534) : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.subject});

  final SubjectModel subject;

  static const _colors = [
    Color(0xFF0891B2),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFFDC2626),
    Color(0xFFEC4899),
    Color(0xFF059669),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[(subject.name.hashCode.abs()) % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        subject.name,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
