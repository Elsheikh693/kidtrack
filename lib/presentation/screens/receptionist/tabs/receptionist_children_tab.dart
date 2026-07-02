import '../../../../index/index_main.dart';
import '../children/receptionist_children_controller.dart';
import '../children/widgets/shift_switcher.dart';
import '../children/widgets/rc_status_filter.dart';
import '../children/widgets/rc_child_card.dart';

class ReceptionistChildrenTab extends StatefulWidget {
  const ReceptionistChildrenTab({super.key});

  @override
  State<ReceptionistChildrenTab> createState() =>
      _ReceptionistChildrenTabState();
}

class _ReceptionistChildrenTabState extends State<ReceptionistChildrenTab> {
  late final ReceptionistChildrenController controller;
  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReceptionistChildrenController());
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('rc_child_search', 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFBFC),
      child: SafeArea(
        bottom: false,
        child: KeyboardActions(
          config: _keyboardService.buildConfig(context, _keys),
          disableScroll: true,
          child: Column(
            children: [
              const _ChildrenTopBar(),
              ShiftSwitcher(controller: controller),
              _SearchRow(
                controller: controller,
                focusNode: _keyboardService.getFocusNode(_keys[0]),
                onAdd: controller.openAddPage,
              ),
              RcStatusFilter(controller: controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.items.isEmpty) {
                    return ChildEmpty(onAdd: controller.openAddPage);
                  }
                  return RefreshIndicator(
                    onRefresh: controller.loadData,
                    child: ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: controller.items.length,
                      itemBuilder: (_, i) {
                        final child = controller.items[i];
                        return RcChildCard(
                          child: child,
                          parentName: controller.parentName(child.key),
                          extraParents: controller.extraParentCount(child.key),
                          classroomName:
                              controller.classroomName(child.classroomId),
                          onTap: () => controller.openProfile(child),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenTopBar extends StatelessWidget {
  const _ChildrenTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      child: Row(
        children: [
          Text(
            'child_list_title'.tr,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () => Get.toNamed(notificationsView),
          ),
          const SizedBox(width: 14),
          _IconBtn(
            icon: Icons.settings_outlined,
            onTap: () => Get.toNamed(settingsView),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 25, color: const Color(0xFF374151)),
      );
}

class _SearchRow extends StatelessWidget {
  final ReceptionistChildrenController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  const _SearchRow({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: controller.searchCtrl,
                      onChanged: (v) => controller.searchQuery.value = v,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF111827)),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'child_search_hint'.tr,
                        hintStyle: const TextStyle(
                            color: Color(0xFFAEB6C4), fontSize: 14),
                      ),
                    ),
                  ),
                  const Icon(Icons.search,
                      color: Color(0xFFAEB6C4), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    size: 22, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'child_register'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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
