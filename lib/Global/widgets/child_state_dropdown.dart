import '../../index/index_main.dart';

/// Pill that shows a child's current state and opens a picker to change it.
/// Shared between the classroom-states sheet and the activity screen.
class ChildStateDropdown extends StatelessWidget {
  const ChildStateDropdown({
    super.key,
    required this.currentId,
    required this.templates,
    required this.onChanged,
    this.currentLabel,
  });

  final String currentId;
  final List<ChildStateTemplateModel> templates;
  final void Function(String stateId, String stateTitle) onChanged;

  /// The child's stored state title (may include a chosen classification, e.g.
  /// "الأكل — كله، نصه"). When provided, the pill shows it verbatim instead of
  /// recomputing from the template name.
  final String? currentLabel;

  static const _green = Color(0xFF16A34A);
  static const _amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final isDefault = currentId == kDefaultStateId;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:
              isDefault ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDefault
                ? _green.withValues(alpha: 0.3)
                : _amber.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDefault ? 'child_state_default'.tr : _labelFor(currentId),
              style: context.typography.xsMedium.copyWith(
                color: isDefault ? _green : _amber,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: isDefault ? _green : _amber,
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(String id) {
    if (id == kDefaultStateId) return 'child_state_default'.tr;
    final stored = currentLabel?.trim() ?? '';
    if (stored.isNotEmpty) return stored;
    final t = templates.where((t) => t.key == id).firstOrNull;
    return t != null ? t.title : 'child_state_default'.tr;
  }

  void _showPicker(BuildContext context) {
    Get.bottomSheet(
      ChildStatePickerSheet(
        currentId: currentId,
        templates: templates,
        onPick: onChanged,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
