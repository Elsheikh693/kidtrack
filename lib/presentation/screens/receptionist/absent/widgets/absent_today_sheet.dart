import '../../../../../index/index_main.dart';

const _amber = Color(0xFFF59E0B);
const _amberBg = Color(0xFFFEF6E7);

/// Bottom sheet listing every child absent today, opened from the "view all" row
/// on the reception home when the inline preview is capped. Reactive: it mirrors
/// the same live [AbsentTodayController] set, so the list flips as check-ins land
/// and tapping a child opens the shared parent chat.
class AbsentTodaySheet extends StatelessWidget {
  const AbsentTodaySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AbsentTodayController>();
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _amberBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_off_outlined,
                      color: _amber, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'reception_absent_today_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.absent.length}',
                    style: context.typography.lgBold.copyWith(color: _amber),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Obx(() {
              final items = controller.absent;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final child = items[i];
                  return AbsentChildTile(
                    child: child,
                    parentName: controller.parentName(child.key),
                    onChat: () => controller.openChat(child),
                    onWhatsApp: () => controller.openWhatsApp(child),
                    hasPhone: controller.hasParentPhone(child.key),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
