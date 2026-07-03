import '../../../../index/index_main.dart';
import 'cities_controller.dart';

class CitiesView extends StatefulWidget {
  const CitiesView({super.key});

  @override
  State<CitiesView> createState() => _CitiesViewState();
}

class _CitiesViewState extends State<CitiesView> {
  late final CitiesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => CitiesController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'cities_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFFEA580C),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'cities_add'.tr,
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
                  Icon(Icons.location_city_outlined,
                      size: 64.sp, color: const Color(0xFFCBD5E1)),
                  SizedBox(height: 16.h),
                  Text(
                    'cities_empty'.tr,
                    style: context.typography.mdRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'cities_empty_sub'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => _CityCard(
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

class _CityCard extends StatelessWidget {
  final CityModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CityCard(
      {required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEA580C);
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
          child: Icon(Icons.location_city_rounded, color: color, size: 22.sp),
        ),
        title: Text(
          item.name,
          style: context.typography.smSemiBold
              .copyWith(color: const Color(0xFF1E293B)),
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
                Icon(Icons.edit_outlined,
                    size: 16.sp, color: const Color(0xFF475569)),
                SizedBox(width: 8.w),
                Text('cities_edit'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline,
                    size: 16.sp, color: const Color(0xFFDC2626)),
                SizedBox(width: 8.w),
                Text('cities_delete'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFFDC2626))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
