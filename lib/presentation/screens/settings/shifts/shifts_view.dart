import '../../../../index/index_main.dart';

class ShiftsView extends StatefulWidget {
  const ShiftsView({super.key});

  @override
  State<ShiftsView> createState() => _ShiftsViewState();
}

class _ShiftsViewState extends State<ShiftsView> {
  late final ShiftsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ShiftsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'shifts_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'shifts_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return const _ShiftsEmpty();
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => ShiftCard(
              item: controller.items[i],
              onEdit: () => controller.openEdit(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _ShiftsEmpty extends StatelessWidget {
  const _ShiftsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(
            'shifts_empty'.tr,
            style: context.typography.mdRegular
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 8.h),
          Text(
            'shifts_empty_sub'.tr,
            style: context.typography.xsRegular
                .copyWith(color: const Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }
}
