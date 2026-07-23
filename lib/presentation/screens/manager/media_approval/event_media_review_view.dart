import '../../../../index/index_main.dart';
import 'media_approval_controller.dart';
import 'widgets/review_photo_tile.dart';

/// Reviewer grid for a single event's pending photos: delete bad ones, retarget
/// audience (everyone or specific children in the branch), then Approve the
/// batch. Mirrors [MediaReviewView] for classroom activities.
class EventMediaReviewView extends StatefulWidget {
  const EventMediaReviewView({super.key});

  @override
  State<EventMediaReviewView> createState() => _EventMediaReviewViewState();
}

class _EventMediaReviewViewState extends State<EventMediaReviewView> {
  late final MediaApprovalController controller;
  late final String? _eventId;

  /// Days the approved photos stay on the parents' home carousel.
  int _bannerDays = 3;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MediaApprovalController>();
    _eventId = Get.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
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
          final event = controller.eventByKey(_eventId);
          final pending = event == null
              ? const []
              : event.photos.entries
                  .where((e) => !e.value.isApproved)
                  .toList();
          if (event == null || pending.isEmpty) {
            return const _EventReviewDone();
          }
          final children = controller.branchChildren;
          return Column(
            children: [
              _EventReviewHeader(
                title: event.title,
                subtitle: event.formattedDate,
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
                        controller.rejectEventPhoto(event, pending[i].key),
                    onSetAudience: (ids) => controller.setEventPhotoAudience(
                        event, pending[i].key, ids),
                  ),
                ),
              ),
              _BannerDaysSelector(
                selected: _bannerDays,
                onChanged: (d) => setState(() => _bannerDays = d),
              ),
              _EventApproveBar(
                count: pending.length,
                onApprove: () =>
                    controller.approveEvent(event, bannerDays: _bannerDays),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _EventReviewHeader extends StatelessWidget {
  const _EventReviewHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.celebration_rounded,
                color: _accent, size: 22),
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
                  subtitle,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}

class _BannerDaysSelector extends StatelessWidget {
  const _BannerDaysSelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _accent = Color(0xFF6366F1);
  static const _options = [1, 3, 7];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      color: AppColors.white,
      child: Row(
        children: [
          Icon(Icons.home_rounded, size: 16.sp, color: _accent),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              'event_banner_days_label'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.grayMedium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          for (final d in _options) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => onChanged(d),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected == d
                      ? _accent
                      : _accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'event_banner_day_count'.trParams({'count': '$d'}),
                  style: context.typography.xsMedium.copyWith(
                    color: selected == d ? Colors.white : _accent,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EventApproveBar extends StatelessWidget {
  const _EventApproveBar({required this.count, required this.onApprove});

  final int count;
  final VoidCallback onApprove;

  static const _accent = Color(0xFF6366F1);

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
            color: _accent,
            borderRadius: BorderRadius.circular(16),
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

class _EventReviewDone extends StatelessWidget {
  const _EventReviewDone();

  static const _accent = Color(0xFF6366F1);

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
