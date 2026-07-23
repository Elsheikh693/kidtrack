import '../../../../../index/index_main.dart';

void showHomeworkFollowUpSheet(
  BuildContext context,
  TeacherActivityController ctrl,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => HomeworkFollowUpSheet(ctrl: ctrl),
  );
}

class HomeworkFollowUpSheet extends StatelessWidget {
  const HomeworkFollowUpSheet({super.key, required this.ctrl});
  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    final hw = ctrl.pendingHomework.value;
    if (hw == null) return const SizedBox.shrink();

    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            _Header(hw: hw),
            Obx(() {
              final total = ctrl.children.length;
              final completed = ctrl.hwCompletedCount;
              final partial = ctrl.hwPartialCount;
              final notCompleted = ctrl.hwNotCompletedCount;
              final absent = ctrl.hwAbsentCount;
              return _StatsBar(
                total: total,
                completed: completed,
                partial: partial,
                notCompleted: notCompleted,
                absent: absent,
              );
            }),
            _BulkBar(ctrl: ctrl),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                final children = ctrl.children;
                if (children.isEmpty) {
                  return Center(child: Text('teacheract33_no_students'.tr));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: children.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (ctx, i) {
                    final child = children[i];
                    final childId = child.key ?? '';
                    return Obx(() => _ChildStatusTile(
                          name: child.fullName,
                          status: ctrl.pendingHomeworkStatuses[childId],
                          onTap: (s) =>
                              ctrl.setHomeworkStatus(childId, s),
                        ));
                  },
                );
              }),
            ),
            _SaveButton(ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

// ── Handle ───────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.hw});
  final HomeworkModel hw;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'teacheract33_hw_followup'.tr,
                  style: context.typography.xsRegular
                      .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 2),
                Text(
                  hw.title,
                  style:
                      context.typography.mdBold.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hw.description != null && hw.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    hw.description!,
                    style: context.typography.xsRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.total,
    required this.completed,
    required this.partial,
    required this.notCompleted,
    required this.absent,
  });
  final int total;
  final int completed;
  final int partial;
  final int notCompleted;
  final int absent;

  @override
  Widget build(BuildContext context) {
    final unmarked = total - completed - partial - notCompleted - absent;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _StatChip(value: completed, label: 'teacheract33_hw_completed'.tr,
              color: const Color(0xFF16A34A)),
          _StatChip(value: partial, label: 'teacheract33_hw_partial'.tr,
              color: const Color(0xFFD97706)),
          _StatChip(value: notCompleted, label: 'teacheract33_hw_not_completed'.tr,
              color: const Color(0xFFDC2626)),
          _StatChip(value: absent, label: 'teacheract33_hw_absent'.tr,
              color: Colors.grey.shade500),
          _StatChip(value: unmarked, label: 'teacheract33_hw_unmarked'.tr,
              color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text('$value',
                style: context.typography.lgBold.copyWith(color: color)),
            Text(label,
                style: context.typography.xsRegular
                    .copyWith(color: Colors.grey.shade500)),
          ],
        ),
      );
}

// ── Bulk Actions ──────────────────────────────────────────────────────────────

class _BulkBar extends StatelessWidget {
  const _BulkBar({required this.ctrl});
  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Text('teacheract33_hw_bulk_all'.tr,
              style: context.typography.xsMedium
                  .copyWith(color: Colors.grey.shade500)),
          const SizedBox(width: 10),
          _BulkBtn(
            label: 'teacheract33_hw_completed'.tr,
            color: const Color(0xFF16A34A),
            onTap: () => ctrl.setAllHomeworkStatus(HomeworkStatus.completed),
          ),
          const SizedBox(width: 6),
          _BulkBtn(
            label: 'teacheract33_hw_partial'.tr,
            color: const Color(0xFFD97706),
            onTap: () =>
                ctrl.setAllHomeworkStatus(HomeworkStatus.partiallyCompleted),
          ),
          const SizedBox(width: 6),
          _BulkBtn(
            label: 'teacheract33_hw_not_completed'.tr,
            color: const Color(0xFFDC2626),
            onTap: () =>
                ctrl.setAllHomeworkStatus(HomeworkStatus.notCompleted),
          ),
          const SizedBox(width: 6),
          _BulkBtn(
            label: 'teacheract33_hw_absent'.tr,
            color: Colors.grey.shade600,
            onTap: () => ctrl.setAllHomeworkStatus(HomeworkStatus.absent),
          ),
        ],
      ),
    );
  }
}

class _BulkBtn extends StatelessWidget {
  const _BulkBtn(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(label,
              style:
                  context.typography.xsMedium.copyWith(color: color)),
        ),
      );
}

// ── Child Status Tile ─────────────────────────────────────────────────────────

class _ChildStatusTile extends StatelessWidget {
  const _ChildStatusTile({
    required this.name,
    required this.status,
    required this.onTap,
  });
  final String name;
  final HomeworkStatus? status;
  final void Function(HomeworkStatus) onTap;

  static const _statuses = [
    HomeworkStatus.completed,
    HomeworkStatus.partiallyCompleted,
    HomeworkStatus.notCompleted,
    HomeworkStatus.absent,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _Avatar(name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: context.typography.smMedium
                  .copyWith(color: const Color(0xFF1F2937)),
            ),
          ),
          Row(
            children: _statuses
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _StatusBtn(
                        status: s,
                        isActive: status == s,
                        onTap: () => onTap(s),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  Color get _color {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF16A34A),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
    ];
    return colors[
        name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: context.typography.smMedium.copyWith(color: _color),
        ),
      );
}

class _StatusBtn extends StatelessWidget {
  const _StatusBtn({
    required this.status,
    required this.isActive,
    required this.onTap,
  });
  final HomeworkStatus status;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.07),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          status.icon,
          color: isActive ? Colors.white : color.withValues(alpha: 0.55),
          size: 17,
        ),
      ),
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.ctrl});
  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () async {
                await ctrl.savePendingHomeworkStatuses();
                Get.back();
              },
              icon: const Icon(Icons.save_rounded, size: 20),
              label: Text('teacheract33_hw_save_followup'.tr,
                  style: context.typography.mdBold),
            ),
          ),
        ),
      );
}
