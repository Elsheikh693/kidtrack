import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/parent_leave_card.dart';
import 'widgets/parent_leave_empty.dart';
import 'widgets/parent_leave_shimmer.dart';

class ParentRequestsHistoryView extends StatefulWidget {
  const ParentRequestsHistoryView({super.key});

  @override
  State<ParentRequestsHistoryView> createState() =>
      _ParentRequestsHistoryViewState();
}

class _ParentRequestsHistoryViewState
    extends State<ParentRequestsHistoryView> {
  late final ParentRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentRequestsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            'parent_req_history_title'.tr,
            style: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
                height: 1,
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.3)),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Column(
          children: [
            _FilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ParentLeaveShimmer();
                }
                if (controller.items.isEmpty) {
                  return ParentLeaveEmpty(onAdd: controller.openAdd);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.items.length,
                  itemBuilder: (_, i) {
                    final item = controller.items[i];
                    return ParentLeaveCard(
                      item: item,
                      childName: controller.childName(item.childId),
                      onDelete: () => controller.delete(item),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ParentRequestsController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final statuses = ['', 'pending', 'approved', 'rejected'];
    final labels = {
      '': 'order_filter_all',
      'pending': 'parent_req_status_pending',
      'approved': 'parent_req_status_approved',
      'rejected': 'parent_req_status_rejected',
    };

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((s) {
            final isSelected = controller.selectedStatus.value == s;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text((labels[s] ?? s).tr),
                selected: isSelected,
                onSelected: (_) => controller.setStatus(s),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDefault,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: AppColors.backgroundNeutral100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderNeutralPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )),
    );
  }
}
