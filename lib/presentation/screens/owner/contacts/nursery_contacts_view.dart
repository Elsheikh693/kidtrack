import '../../../../index/index_main.dart';

class NurseryContactsView extends StatefulWidget {
  const NurseryContactsView({super.key});

  @override
  State<NurseryContactsView> createState() => _NurseryContactsViewState();
}

class _NurseryContactsViewState extends State<NurseryContactsView> {
  late final NurseryContactsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryContactsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'nursery_contact_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'nursery_contact_add_fab'.tr,
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
                  const Icon(Icons.contact_phone_outlined,
                      size: 64, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  Text(
                    'nursery_contact_empty'.tr,
                    style: context.typography.mdRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'nursery_contact_empty_sub'.tr,
                    textAlign: TextAlign.center,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => _ContactCard(
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

class _ContactCard extends StatelessWidget {
  final NurseryContactModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: color, size: 22),
        ),
        title: Text(
          item.name,
          style: context.typography.smSemiBold
              .copyWith(color: const Color(0xFF1E293B)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.roleLabelTrKey.tr,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
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
                const Icon(Icons.edit_outlined,
                    size: 16, color: Color(0xFF475569)),
                const SizedBox(width: 8),
                Text('nursery_contact_edit_action'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_outline,
                    size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Text('nursery_contact_delete'.tr,
                    style: const TextStyle(color: Color(0xFFDC2626))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
