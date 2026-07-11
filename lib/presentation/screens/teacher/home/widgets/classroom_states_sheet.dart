import '../../../../../index/index_main.dart';
import 'classroom_state_tile.dart';

/// Bottom sheet listing every child in a classroom with their live state, so the
/// teacher can check children in and move them between states without leaving
/// the home screen.
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
  static const _ink = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.groups_rounded,
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'child_state_classroom_sheet_title'.tr,
                          style: context.typography.mdBold.copyWith(color: _ink),
                        ),
                        Obx(() => Text(
                              controller.classroomName.value,
                              style: context.typography.xsRegular
                                  .copyWith(color: const Color(0xFF6B7280)),
                            )),
                      ],
                    ),
                  ),
                  // Present / total counter
                  Obx(() {
                    if (controller.children.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.how_to_reg_rounded,
                              size: 15, color: _accent),
                          const SizedBox(width: 5),
                          Text(
                            '${controller.presentCount}/${controller.children.length}',
                            style: context.typography.smSemiBold
                                .copyWith(color: _accent),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Body
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = controller.sortedChildren;
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'child_state_no_children'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.62,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => ClassroomStateTile(
                    controller: controller,
                    child: list[i],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
