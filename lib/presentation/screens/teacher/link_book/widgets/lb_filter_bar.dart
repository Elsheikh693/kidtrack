import '../../../../../index/index_main.dart';

class LbFilterBar extends GetView<LinkBookController> {
  const LbFilterBar({super.key});

  static const _kBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            _FilterChip(
              icon: Icons.calendar_today_rounded,
              label: controller.formattedDate,
              color: _kBlue,
              onTap: () => _showDatePicker(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterChip(
                icon: Icons.meeting_room_rounded,
                label: controller.selectedClassroom?.name ?? 'teacherlin37_classroom'.tr,
                color: const Color(0xFF059669),
                onTap: () => _showClassroomPicker(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterChip(
                icon: Icons.child_care_rounded,
                label: controller.selectedChild?.firstName ?? 'teacherlin37_all'.tr,
                color: const Color(0xFFD97706),
                onTap: () => _showChildPicker(context),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: controller.selectedDate.value,
      minimumDate: DateTime.now().subtract(const Duration(days: 90)),
      maximumDate: DateTime.now(),
    );
    if (picked != null) controller.selectDate(picked);
  }

  void _showClassroomPicker(BuildContext context) {
    Get.bottomSheet(
      _PickerSheet<ClassroomModel>(
        title: 'teacherlin37_pick_classroom'.tr,
        items: controller.classrooms,
        selectedId: controller.selectedClassroomId.value,
        labelOf: (c) => c.name,
        idOf: (c) => c.key ?? '',
        onSelect: (id) => controller.selectClassroom(id),
        color: const Color(0xFF059669),
      ),
      isScrollControlled: true,
    );
  }

  void _showChildPicker(BuildContext context) {
    Get.bottomSheet(
      _ChildPickerSheet(
        children: controller.children,
        selectedId: controller.selectedChildId.value,
        onSelect: (id) => controller.selectChild(id),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Filter chip button ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: context.typography.xsMedium.copyWith(
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic picker sheet ──────────────────────────────────────────────────────

class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String? selectedId;
  final String Function(T) labelOf;
  final String Function(T) idOf;
  final void Function(String?) onSelect;
  final Color color;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.labelOf,
    required this.idOf,
    required this.onSelect,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((item) {
            final id = idOf(item);
            final selected = id == selectedId;
            return _OptionTile(
              label: labelOf(item),
              selected: selected,
              color: color,
              onTap: () {
                onSelect(id);
                Get.back();
              },
            );
          }),
        ],
      ),
    );
  }
}

// ── Child picker with "الكل" option ──────────────────────────────────────────

class _ChildPickerSheet extends StatelessWidget {
  final List<ChildModel> children;
  final String? selectedId;
  final void Function(String?) onSelect;

  const _ChildPickerSheet({
    required this.children,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('teacherlin37_pick_child'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _OptionTile(
            label: 'teacherlin37_all_class_report'.tr,
            selected: selectedId == null,
            color: const Color(0xFFD97706),
            onTap: () {
              onSelect(null);
              Get.back();
            },
          ),
          ...children.map((child) {
            final selected = child.key == selectedId;
            return _OptionTile(
              label: child.fullName,
              selected: selected,
              color: const Color(0xFFD97706),
              onTap: () {
                onSelect(child.key);
                Get.back();
              },
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : const Color(0xFF374151),
                ),
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
