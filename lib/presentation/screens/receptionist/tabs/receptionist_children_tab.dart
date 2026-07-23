import '../../../../index/index_main.dart';
import '../children/receptionist_children_controller.dart';
import '../children/widgets/shift_switcher.dart';
import '../children/widgets/rc_withdrawn_card.dart';
import '../children/widgets/rc_invite_parents_card.dart';
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
      child: KeyboardActions(
        config: _keyboardService.buildConfig(context, _keys),
        disableScroll: true,
        child: Column(
          children: [
            AppTitleBar(
              title: 'child_list_title'.tr,
              onNotificationTap: () => Get.toNamed(notificationsView),
              onSettingsTap: () => Get.toNamed(settingsView),
            ),
            // Everything below the title bar scrolls together — the stat
            // cards, search, and withdrawn card scroll away with the list.
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                child: Obx(() {
                  // Rebuild the list when conversations change so per-card
                  // unread badges stay live.
                  controller.chatConvos.length;
                  final loading = controller.isLoading.value;
                  final items = controller.items;
                  return CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ShiftSwitcher(controller: controller),
                            _SearchRow(
                              controller: controller,
                              focusNode: _keyboardService.getFocusNode(
                                _keys[0],
                              ),
                              onAdd: controller.openAddPage,
                            ),
                            RcWithdrawnCard(controller: controller),
                            RcInviteParentsCard(controller: controller),
                          ],
                        ),
                      ),
                      if (loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (items.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: ChildEmpty(onAdd: controller.openAddPage),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((_, i) {
                              final child = items[i];
                              return RcChildCard(
                                child: child,
                                parentName: controller.parentName(child.key),
                                extraParents: controller.extraParentCount(
                                  child.key,
                                ),
                                classroomName: controller.classroomName(
                                  child.classroomId,
                                ),
                                onTap: () => controller.openProfile(child),
                                onChat: () => controller.openChat(child),
                                chatUnread: controller.chatUnread(child.key),
                                shiftStartMinutes:
                                    controller.shiftStart(child.shift),
                              );
                            }, childCount: items.length),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'child_search_hint'.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFFAEB6C4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.search, color: Color(0xFFAEB6C4), size: 20),
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
                Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
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
