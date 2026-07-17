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
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textDefault),
          title: AppText(
            text: 'media_review_title'.tr,
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFEDEFF3)),
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
            return const _ReviewDone();
          }
          final children = controller.childrenFor(activity.classroomId);
          return Column(
            children: [
              _ReviewHeader(
                title: (activity.subjectName?.isNotEmpty == true)
                    ? activity.subjectName!
                    : activity.title,
                classroomName: controller.classroomName(activity.classroomId),
                startedAt: activity.startedAt,
                count: pending.length,
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 16.h),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.82,
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

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.title,
    required this.classroomName,
    required this.startedAt,
    required this.count,
  });

  final String title;
  final String classroomName;
  final int startedAt;
  final int count;

  static const _accent = Color(0xFF0891B2);

  String get _time {
    final d = DateTime.fromMillisecondsSinceEpoch(startedAt);
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF22B8D6), _accent],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (classroomName.isNotEmpty) classroomName,
                        _time,
                      ].join('  ·  '),
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.grayMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'media_pending_count'.trParams({'count': '$count'}),
                  style: context.typography.xsMedium.copyWith(color: _accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApproveBar extends StatelessWidget {
  const _ApproveBar({required this.count, required this.onApprove});

  final int count;
  final VoidCallback onApprove;

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEFF3))),
      ),
      child: GestureDetector(
        onTap: onApprove,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF22B8D6), _accent],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'media_approve_all'.trParams({'count': '$count'}),
                style: context.typography.mdBold.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewDone extends StatelessWidget {
  const _ReviewDone();

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                size: 42, color: _accent),
          ),
          const SizedBox(height: 16),
          Text(
            'media_review_done'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}
