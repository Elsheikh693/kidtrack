import '../../../../index/index_main.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late final PaymentController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PaymentController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'payment_screen_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFFD97706),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'payment_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const PaymentShimmer();
          if (controller.items.isEmpty) return const PaymentEmpty();
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final item = controller.items[i];
                return PaymentCard(
                  item: item,
                  childName: controller.childName(item.childId),
                  categoryName: item.categoryName,
                  onDelete: () => controller.delete(item),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
