import '../../../../index/index_main.dart';
import 'media_approval_controller.dart';
import 'widgets/review_photo_tile.dart';

class MediaReviewView extends StatefulWidget {
  const MediaReviewView({super.key});

  @override
  State<MediaReviewView> createState() => _MediaReviewViewState();
}

class _MediaReviewViewState extends State<MediaReviewView> {
  late final MediaApprovalController controller;
  late final String? _activityKey;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MediaApprovalController>();
    _activityKey = Get.arguments as String?;
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
            text: 'media_review_title'.tr,
            textStyle: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          final activity = controller.activityByKey(_activityKey);
          final pending = activity == null
              ? const []
              : activity.photos.entries
                  .where((e) => !e.value.isApproved)
                  .toList();
          if (activity == null || pending.isEmpty) {
            return Center(
              child: Text(
                'media_review_done'.tr,
                style: context.typography.smMedium
                    .copyWith(color: Colors.grey.shade500),
              ),
            );
          }
          final children = controller.childrenFor(activity.classroomId);
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: pending.length,
                  itemBuilder: (_, i) => ReviewPhotoTile(
                    photo: pending[i].value,
                    children: children,
                    onReject: () =>
                        controller.rejectPhoto(activity, pending[i].key),
                    onSetAudience: (ids) => controller.setPhotoAudience(
                        activity, pending[i].key, ids),
                  ),
                ),
              ),
              _ApproveBar(
                count: pending.length,
                onApprove: () => controller.approveActivity(activity),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ApproveBar extends StatelessWidget {
  const _ApproveBar({required this.count, required this.onApprove});

  final int count;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: PrimaryTextButton(
        appButtonSize: AppButtonSize.xxLarge,
        onTap: onApprove,
        label: AppText(
          text: 'media_approve_all'.trParams({'count': '$count'}),
          textStyle: context.typography.mdBold.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
