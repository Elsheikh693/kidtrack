import '../../../../../index/index_main.dart';

class ClassroomStatesSheet extends StatefulWidget {
  const ClassroomStatesSheet({super.key});

  @override
  State<ClassroomStatesSheet> createState() => _ClassroomStatesSheetState();
}

class _ClassroomStatesSheetState extends State<ClassroomStatesSheet> {
  late final ClassroomStatesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClassroomStatesController>();
  }

  static const _accent = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: _accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'child_state_classroom_sheet_title'.tr,
                          style: context.typography.mdBold.copyWith(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Obx(() => Text(
                              controller.classroomName.value,
                              style: context.typography.xsRegular.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Body
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.children.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'child_state_no_children'.tr,
                    style: context.typography.smRegular.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                  itemCount: controller.children.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 72,
                  ),
                  itemBuilder: (_, i) {
                    final child = controller.children[i];
                    final childId = child.key ?? '';
                    return _ChildStateTile(
                      child: child,
                      controller: controller,
                      childId: childId,
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Child State Tile ──────────────────────────────────────────────────────────

class _ChildStateTile extends StatelessWidget {
  final ChildModel child;
  final ClassroomStatesController controller;
  final String childId;

  const _ChildStateTile({
    required this.child,
    required this.controller,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final checkedIn = controller.isCheckedIn(childId);
      final currentId = controller.stateIdFor(childId);

      return Opacity(
        opacity: checkedIn ? 1.0 : 0.45,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    const Color(0xFF7C3AED).withValues(alpha: 0.1),
                backgroundImage: child.profileImage != null
                    ? appCachedImageProvider(child.profileImage!)
                    : null,
                child: child.profileImage == null
                    ? Text(
                        child.firstName.isNotEmpty
                            ? child.firstName[0]
                            : '?',
                        style: context.typography.mdBold.copyWith(
                          color: const Color(0xFF7C3AED),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Text(
                  child.fullName,
                  style: context.typography.smSemiBold.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),

              // State dropdown
              if (!checkedIn)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'child_state_not_present'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                _StateDropdown(
                  currentId: currentId,
                  templates: controller.templates,
                  onChanged: (stateId, stateTitle) =>
                      controller.updateState(childId, stateId, stateTitle),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ── State Dropdown ────────────────────────────────────────────────────────────

class _StateDropdown extends StatelessWidget {
  final String currentId;
  final List<ChildStateTemplateModel> templates;
  final void Function(String stateId, String stateTitle) onChanged;

  const _StateDropdown({
    required this.currentId,
    required this.templates,
    required this.onChanged,
  });

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final isDefault = currentId == kDefaultStateId;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDefault
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDefault
                ? _green.withValues(alpha: 0.3)
                : const Color(0xFFD97706).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDefault
                  ? 'child_state_default'.tr
                  : _labelFor(currentId),
              style: context.typography.xsMedium.copyWith(
                color: isDefault ? _green : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: isDefault ? _green : const Color(0xFFD97706),
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
      ...templates.map((t) => (id: t.key ?? '', label: '${t.icon} ${t.title}')),
    ];

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                        color: selected
                            ? _green
                            : const Color(0xFF1E293B),
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
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
