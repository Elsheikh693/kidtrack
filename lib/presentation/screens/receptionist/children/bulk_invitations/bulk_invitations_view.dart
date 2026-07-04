import '../../../../../index/index_main.dart';
import 'widgets/bulk_invite_summary.dart';
import 'widgets/bulk_invite_filter_bar.dart';
import 'widgets/bulk_invite_search.dart';
import 'widgets/bulk_invite_parent_card.dart';
import 'widgets/bulk_invite_empty.dart';

class BulkInvitationsView extends StatefulWidget {
  const BulkInvitationsView({super.key});

  @override
  State<BulkInvitationsView> createState() => _BulkInvitationsViewState();
}

class _BulkInvitationsViewState extends State<BulkInvitationsView> {
  late final BulkInvitationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BulkInvitationsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'rc_bulk_invite_title'.tr,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20.sp, color: const Color(0xFF374151)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return Column(
            children: [
              BulkInviteSummary(controller: controller),
              BulkInviteSearch(controller: controller),
              BulkInviteFilterBar(controller: controller),
              Expanded(
                child: controller.filtered.isEmpty
                    ? const BulkInviteEmpty()
                    : RefreshIndicator(
                        onRefresh: controller.loadData,
                        child: ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 24.h),
                          itemCount: controller.filtered.length,
                          itemBuilder: (_, i) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: BulkInviteParentCard(
                              row: controller.filtered[i],
                              onSend: () =>
                                  controller.send(controller.filtered[i]),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
