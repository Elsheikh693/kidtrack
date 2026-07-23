import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/pickup_request_card.dart';

class PickupRequestsView extends StatefulWidget {
  const PickupRequestsView({super.key});

  @override
  State<PickupRequestsView> createState() => _PickupRequestsViewState();
}

class _PickupRequestsViewState extends State<PickupRequestsView> {
  late final PickupRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PickupRequestsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'reception_pickup_requests_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _StatusFilterBar(controller: controller),
              Expanded(child: _RequestsList(controller: controller)),
            ],
          );
        }),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final PickupRequestsController controller;
  const _StatusFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: controller.statuses.map((s) {
            final isSelected = controller.selectedStatus.value == s;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text('pickup_status_$s'.tr),
                selected: isSelected,
                onSelected: (_) => controller.filterByStatus(s),
                selectedColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                checkmarkColor: const Color(0xFF7C3AED),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF7C3AED)
                      : AppColors.textSecondaryParagraph,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final PickupRequestsController controller;
  const _RequestsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filtered;
      if (list.isEmpty) {
        return Center(
          child: Text(
            'pickup_requests_empty'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async { controller.onInit(); },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: list.length,
          itemBuilder: (_, i) =>
              PickupRequestCard(request: list[i], controller: controller),
        ),
      );
    });
  }
}
