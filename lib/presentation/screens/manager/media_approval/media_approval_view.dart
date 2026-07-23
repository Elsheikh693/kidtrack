import '../../../../index/index_main.dart';
import 'media_approval_controller.dart';
import 'media_review_view.dart';
import 'event_media_review_view.dart';
import 'widgets/pending_activity_card.dart';
import 'widgets/pending_event_card.dart';

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
      textDirection: appTextDirection,
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
          final activities = controller.pendingActivities;
          final events = controller.pendingEvents;
          if (activities.isEmpty && events.isEmpty) {
            return const _MediaApprovalEmpty();
          }
          final showLabels = activities.isNotEmpty && events.isNotEmpty;
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
            children: [
              if (activities.isNotEmpty) ...[
                if (showLabels) _SectionLabel('media_section_activities'.tr),
                ...activities.map((a) => PendingActivityCard(
                      activity: a,
                      classroomName: controller.classroomName(a.classroomId),
                      onReview: () => Get.to(
                        () => const MediaReviewView(),
                        arguments: a.key,
                      ),
                    )),
              ],
              if (events.isNotEmpty) ...[
                if (showLabels) _SectionLabel('media_section_events'.tr),
                ...events.map((e) => PendingEventCard(
                      event: e,
                      onReview: () => Get.to(
                        () => const EventMediaReviewView(),
                        arguments: e.id,
                      ),
                    )),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 10.h),
      child: Text(
        label,
        style: context.typography.smSemiBold
            .copyWith(color: AppColors.textSecondaryParagraph),
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
