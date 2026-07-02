import '../../../index/index_main.dart';
import 'widgets/chat_child_tile.dart';

const _muted = Color(0xFF8A93A4);

/// Manager-side chat inbox tab: searchable list of children, each linked to its
/// parent, tapping opens the shared conversation thread.
class ManagerChatTab extends StatefulWidget {
  const ManagerChatTab({super.key});

  @override
  State<ManagerChatTab> createState() => _ManagerChatTabState();
}

class _ManagerChatTabState extends State<ManagerChatTab> {
  late final ChatListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChatListController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: OwnerAppBar(
        title: 'chat_title'.tr,
        onBack: () => Get.find<MainPageViewModel>().changePage(0),
      ),
      body: Column(
        children: [
          _SearchBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.items;
              if (items.isEmpty) return const _EmptyState();
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final child = items[i];
                  return ChatChildTile(
                    name: child.fullName,
                    parentName: controller.parentName(child.key),
                    imageUrl: child.profileImage,
                    convo: controller.convoFor(child.key),
                    onTap: () => controller.openThread(child),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final ChatListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20.sp, color: _muted),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: controller.searchCtrl,
                onChanged: (v) => controller.searchQuery.value = v,
                style: context.typography.smRegular.copyWith(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'chat_search_hint'.tr,
                  hintStyle: context.typography.smRegular.copyWith(
                    color: _muted,
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'chat_empty_children'.tr,
            style: context.typography.mdMedium
                .copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
