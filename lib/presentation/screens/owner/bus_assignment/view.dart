import '../../../../index/index_main.dart';

class BusAssignmentView extends StatefulWidget {
  const BusAssignmentView({super.key});

  @override
  State<BusAssignmentView> createState() => _BusAssignmentViewState();
}

class _BusAssignmentViewState extends State<BusAssignmentView> {
  late final BusAssignmentController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => BusAssignmentController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'bus_assign_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.chaperones.isEmpty) {
            return _EmptyChaperones();
          }
          return Column(
            children: [
              _ChaperonePicker(controller: controller),
              Expanded(
                child: controller.children.isEmpty
                    ? _EmptyChildren()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: controller.children.length,
                        itemBuilder: (_, i) {
                          final child = controller.children[i];
                          return _ChildTile(
                            controller: controller,
                            child: child,
                          );
                        },
                      ),
              ),
              _SaveBar(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _ChaperonePicker extends StatelessWidget {
  const _ChaperonePicker({required this.controller});
  final BusAssignmentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bus_assign_chaperone_label'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: Obx(() {
              final selected = controller.selectedChaperone.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.chaperones.length,
                separatorBuilder: (_, i) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = controller.chaperones[i];
                  final isSel = s.uid == selected?.uid;
                  return GestureDetector(
                    onTap: () => controller.selectChaperone(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.backgroundNeutral100,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: isSel
                              ? AppColors.primary
                              : AppColors.borderNeutralPrimary
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSel ? AppColors.white : AppColors.textDefault,
                        ),
                      ),
                    ),
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

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.controller, required this.child});
  final BusAssignmentController controller;
  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOn = controller.assigned[child.key ?? ''] ?? false;
      final hasLocation = child.hasHomeLocation;
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOn
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.location_on : Icons.location_off_outlined,
              size: 18,
              color: hasLocation ? AppColors.primary : AppColors.grayMedium,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textDefault),
                  ),
                  if (!hasLocation)
                    Text(
                      'bus_assign_no_location'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isOn,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => controller.toggle(child),
            ),
          ],
        ),
      );
    });
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.controller});
  final BusAssignmentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() => Text(
                'bus_assign_count'.trParams({
                  'count': '${controller.assignedCount}',
                }),
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              )),
          const Spacer(),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isSaving.value ? null : controller.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'bus_assign_save'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              )),
        ],
      ),
    );
  }
}

class _EmptyChaperones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus_outlined,
              size: 48, color: AppColors.grayMedium),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'bus_assign_no_chaperones'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChildren extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'bus_assign_no_children'.tr,
        style: context.typography.smRegular
            .copyWith(color: AppColors.textSecondaryParagraph),
      ),
    );
  }
}
