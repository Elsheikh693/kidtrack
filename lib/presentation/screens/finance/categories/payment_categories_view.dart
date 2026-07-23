import '../../../../index/index_main.dart';

class PaymentCategoriesView extends StatefulWidget {
  const PaymentCategoriesView({super.key});

  @override
  State<PaymentCategoriesView> createState() => _PaymentCategoriesViewState();
}

class _PaymentCategoriesViewState extends State<PaymentCategoriesView> {
  late final PaymentCategoriesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PaymentCategoriesController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'finance_cat_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFFD97706),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'finance_cat_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined, size: 64.sp, color: const Color(0xFFCBD5E1)),
                  SizedBox(height: 16.h),
                  Text(
                    'finance_cat_empty'.tr,
                    style: context.typography.mdRegular.copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'finance_cat_empty_sub'.tr,
                    style: context.typography.xsRegular.copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => _CategoryCard(
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

class _CategoryCard extends StatelessWidget {
  final PaymentCategoryModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        leading: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.wallet_rounded, color: color, size: 22.sp),
        ),
        title: Text(
          item.name,
          style: context.typography.smSemiBold.copyWith(color: const Color(0xFF1E293B)),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            item.isActive ? 'finance_cat_active'.tr : 'finance_cat_inactive'.tr,
            style: context.typography.xsMedium.copyWith(fontSize: 11, color: color),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 16.sp, color: const Color(0xFF475569)),
                SizedBox(width: 8.w),
                Text('finance_cat_edit_action'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 16.sp, color: const Color(0xFFDC2626)),
                SizedBox(width: 8.w),
                Text('finance_cat_delete'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
