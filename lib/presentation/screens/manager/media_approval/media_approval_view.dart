import '../../../../index/index_main.dart';
import 'media_approval_controller.dart';
import 'media_review_view.dart';
import 'widgets/pending_activity_card.dart';

class MediaApprovalView extends StatefulWidget {
  const MediaApprovalView({super.key});

  @override
  State<MediaApprovalView> createState() => _MediaApprovalViewState();
}

class _MediaApprovalViewState extends State<MediaApprovalView> {
  late final MediaApprovalController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MediaApprovalController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textDefault),
          title: AppText(
            text: 'media_approval_title'.tr,
            textStyle: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final items = controller.pendingActivities;
          if (items.isEmpty) return const _MediaApprovalEmpty();
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
            itemCount: items.length,
            itemBuilder: (_, i) => PendingActivityCard(
              activity: items[i],
              classroomName: controller.classroomName(items[i].classroomId),
              onReview: () => Get.to(
                () => const MediaReviewView(),
                arguments: items[i].key,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MediaApprovalEmpty extends StatelessWidget {
  const _MediaApprovalEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'media_approval_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
