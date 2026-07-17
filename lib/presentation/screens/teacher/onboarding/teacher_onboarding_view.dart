import '../../../../index/index_main.dart';
import 'teacher_onboarding_controller.dart';

class TeacherOnboardingView extends StatelessWidget {
  const TeacherOnboardingView({super.key, this.editMode = false});

  final bool editMode;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TeacherOnboardingController(editMode: editMode));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Obx(() {
            if (c.isLoading.value) {
              return const _OnboardingShimmer();
            }
            return Column(
              children: [
                _Header(controller: c),
                Expanded(
                  child: PageView(
                    controller: c.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Step1Classrooms(c: c),
                      _Step2Matrix(c: c),
                    ],
                  ),
                ),
                _BottomBar(c: c),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final TeacherOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;
      final titles = ['اختاري الفصول التي تدرسينها', 'حددي مواد كل فصل'];
      final subtitles = [
        'ضعي علامة على كل فصل تتولين تدريسه',
        'اختاري المواد لكل فصل من الجدول أدناه',
      ];
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (controller.editMode) ...[
                      _CircleIconButton(
                        icon: Icons.close_rounded,
                        onTap: () => Get.back(),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.editMode
                                ? 'تعديل الملف الأكاديمي'
                                : 'إعداد الملف الأكاديمي',
                            style: context.typography.smSemiBold
                                .copyWith(color: Colors.white),
                          ),
                          Text(
                            'خطوة ${step + 1} من 2',
                            style: context.typography.xsRegular.copyWith(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    if (controller.totalAssignments > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${controller.totalAssignments} تكليف',
                          style: context.typography.xsMedium
                              .copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(step),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[step],
                        style: context.typography.mdBold
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitles[step],
                        style: context.typography.xsRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Step indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: List.generate(2, (i) {
                final active = i == step;
                final done = i < step;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: done || active
                                ? const Color(0xFF16A34A)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      if (i < 1) const SizedBox(width: 6),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }
}

// ── Step 1: Classroom selection ───────────────────────────────────────────────

class _Step1Classrooms extends StatelessWidget {
  const _Step1Classrooms({required this.c});
  final TeacherOnboardingController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.allClassrooms.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.meeting_room_outlined,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'لا توجد فصول في هذا الفرع',
                  style: context.typography.smRegular.copyWith(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Text(
                  'تواصلي مع مدير الحضانة',
                  style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        );
      }

      final selectedCount = c.selectedClassroomIds.length;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 0, 12),
            child: Row(
              children: [
                Text(
                  'الفصول الدراسية المتاحة',
                  style: context.typography.displaySmBold.copyWith(color: Color(0xFF374151)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$selectedCount محدد',
                    style: context.typography.xsMedium.copyWith(color: Color(0xFF16A34A)),
                  ),
                ),
              ],
            ),
          ),
          ...c.allClassrooms.map((cl) {
            final selected = c.isClassroomSelected(cl.key ?? '');
            return _ClassroomTile(
              name: cl.name,
              capacity: cl.capacity,
              selected: selected,
              onTap: () => c.toggleClassroom(cl.key ?? ''),
            );
          }),
        ],
      );
    });
  }
}

class _ClassroomTile extends StatelessWidget {
  const _ClassroomTile({
    required this.name,
    required this.capacity,
    required this.selected,
    required this.onTap,
  });
  final String name;
  final int? capacity;
  final bool selected;
  final VoidCallback onTap;

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? _green.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _green : Colors.grey.shade200,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? _green.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: selected ? 12 : 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? _green.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.meeting_room_rounded,
                    color: selected ? _green : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.typography.displaySmBold.copyWith(
                          color: selected ? const Color(0xFF111827) : const Color(0xFF374151),
                        ),
                      ),
                      if (capacity != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'السعة: $capacity طالب',
                          style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? _green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _green : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Matrix ────────────────────────────────────────────────────────────

class _Step2Matrix extends StatelessWidget {
  const _Step2Matrix({required this.c});
  final TeacherOnboardingController c;

  static const _green = Color(0xFF16A34A);
  static const _cellSize = 52.0;
  static const _rowLabelWidth = 130.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classrooms = c.selectedClassrooms;
      final subjects = c.allSubjects;

      if (subjects.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'لا توجد مواد دراسية',
                  style: context.typography.smRegular.copyWith(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Text(
                  'تواصلي مع مدير الحضانة لإضافة المواد',
                  style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: _green.withValues(alpha: 0.8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اضغطي على عنوان العمود لتحديد المادة لجميع الفصول، أو على اسم الفصل لتحديد جميع مواده',
                    style: context.typography.xsRegular.copyWith(color: const Color(0xFF166534).withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Matrix table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      // Header row
                      Row(
                        children: [
                          // Corner cell
                          SizedBox(
                            width: _rowLabelWidth,
                            height: _cellSize,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                ),
                                border: Border.all(
                                    color: Colors.grey.shade200),
                              ),
                              child: Center(
                                child: Text(
                                  'الفصل \\ المادة',
                                  style: context.typography.xsMedium.copyWith(color: Color(0xFF6B7280)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // Subject column headers
                          ...subjects.map((s) {
                            return Obx(() {
                              final allChecked =
                                  c.isColumnAllChecked(s.key ?? '');
                              return GestureDetector(
                                onTap: () =>
                                    c.toggleEntireColumn(s.key ?? ''),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: _cellSize + 20,
                                  height: _cellSize,
                                  decoration: BoxDecoration(
                                    color: allChecked
                                        ? _green.withValues(alpha: 0.12)
                                        : Colors.grey.shade50,
                                    border: Border.all(
                                        color: allChecked
                                            ? _green.withValues(alpha: 0.4)
                                            : Colors.grey.shade200),
                                  ),
                                  child: Center(
                                    child: Text(
                                      s.name,
                                      style: context.typography.xsMedium.copyWith(color: allChecked ? _green : const Color(0xFF374151)),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ],
                      ),
                      // Data rows
                      ...classrooms.asMap().entries.map((entry) {
                        final i = entry.key;
                        final cl = entry.value;
                        final isLast = i == classrooms.length - 1;
                        return Row(
                          children: [
                            // Row label
                            GestureDetector(
                              onTap: () =>
                                  c.toggleEntireRow(cl.key ?? ''),
                              child: Obx(() {
                                final allChecked =
                                    c.isRowAllChecked(cl.key ?? '');
                                return AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: _rowLabelWidth,
                                  height: _cellSize,
                                  decoration: BoxDecoration(
                                    color: allChecked
                                        ? _green.withValues(alpha: 0.1)
                                        : Colors.white,
                                    borderRadius: isLast
                                        ? const BorderRadius.only(
                                            bottomRight:
                                                Radius.circular(12))
                                        : null,
                                    border: Border.all(
                                        color: allChecked
                                            ? _green.withValues(alpha: 0.35)
                                            : Colors.grey.shade200),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            cl.name,
                                            style: context.typography.xsMedium.copyWith(color: allChecked ? _green : const Color(0xFF374151)),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (allChecked)
                                          Icon(
                                            Icons.done_all_rounded,
                                            size: 14,
                                            color: _green,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // Subject cells
                            ...subjects.map((s) {
                              final cId = cl.key ?? '';
                              final sId = s.key ?? '';
                              return Obx(() {
                                final checked =
                                    c.isMatrixChecked(cId, sId);
                                return GestureDetector(
                                  onTap: () =>
                                      c.toggleCell(cId, sId),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    width: _cellSize + 20,
                                    height: _cellSize,
                                    decoration: BoxDecoration(
                                      color: checked
                                          ? _green.withValues(alpha: 0.1)
                                          : Colors.white,
                                      border: Border.all(
                                          color: checked
                                              ? _green.withValues(
                                                  alpha: 0.35)
                                              : Colors.grey.shade100),
                                    ),
                                    child: Center(
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 150),
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: checked
                                              ? _green
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: checked
                                                ? _green
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: checked
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Loading Shimmer ───────────────────────────────────────────────────────────

class _OnboardingShimmer extends StatelessWidget {
  const _OnboardingShimmer();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header placeholder — real gradient so the open transition is smooth.
        Container(
          padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF15803D)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ghost(38, 38, radius: 12),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ghost(120, 12),
                      const SizedBox(height: 6),
                      _ghost(70, 10, alpha: 0.6),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ghost(230, 16),
              const SizedBox(height: 8),
              _ghost(170, 12, alpha: 0.6),
            ],
          ),
        ),
        // List placeholder.
        Expanded(
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF8FAFC),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16, right: 4),
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                for (var i = 0; i < 5; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ghost(double width, double height,
      {double radius = 6, double alpha = 0.35}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Circle Icon Button ────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.c});
  final TeacherOnboardingController c;

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = c.currentStep.value;
      final isLast = step == 1;
      final isSaving = c.isSaving.value;

      return Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (step > 0)
              OutlinedButton(
                onPressed: isSaving ? null : c.prevStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF374151)),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed:
                    isSaving ? null : (isLast ? c.saveAndFinish : c.nextStep),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast
                                ? (c.editMode ? 'حفظ التعديلات' : 'حفظ وابدأي')
                                : 'التالي',
                            style: context.typography.mdBold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
