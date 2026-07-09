import '../../index/index_main.dart';

/// Pill that shows a child's current state and opens a picker to change it.
/// Shared between the classroom-states sheet and the activity screen.
class ChildStateDropdown extends StatelessWidget {
  const ChildStateDropdown({
    super.key,
    required this.currentId,
    required this.templates,
    required this.onChanged,
  });

  final String currentId;
  final List<ChildStateTemplateModel> templates;
  final void Function(String stateId, String stateTitle) onChanged;

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
    final t = templates.where((t) => t.key == id).firstOrNull;
    return t != null ? '${t.icon} ${t.title}' : 'child_state_default'.tr;
  }

  void _showPicker(BuildContext context) {
    final items = <({String id, String label})>[
      (id: kDefaultStateId, label: 'child_state_default'.tr),
      ...templates
          .map((t) => (id: t.key ?? '', label: '${t.icon} ${t.title}')),
    ];

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'child_state_pick'.tr,
                  style: context.typography.mdBold.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final selected = currentId == item.id;
                  return ListTile(
                    leading: selected
                        ? const Icon(Icons.check_circle_rounded,
                            color: _green, size: 20)
                        : const SizedBox(width: 20),
                    title: Text(
                      item.label,
                      style: context.typography.smMedium.copyWith(
                        color: selected ? _green : const Color(0xFF1E293B),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      if (item.id != currentId) {
                        onChanged(item.id, item.label);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
