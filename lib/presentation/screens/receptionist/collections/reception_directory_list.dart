import '../../../../index/index_main.dart';
import 'reception_collection_controller.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);
const _bg = Color(0xFFF6F7FB);

/// Default reception "الماليات" state: the whole in-scope children directory as
/// compact single-row cards. Each card carries two quick actions — one-tap
/// "renew monthly subscription" and "open full payment history" (the same
/// per-child view the search flow opens). The exact same [CollectionChildCard]
/// backs the search results, so both lists look identical.
class ReceptionDirectoryList extends StatelessWidget {
  final ReceptionCollectionController controller;
  final ValueChanged<ChildModel> onHistory;
  final ValueChanged<ChildModel> onRenew;

  const ReceptionDirectoryList({
    super.key,
    required this.controller,
    required this.onHistory,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final children = controller.children;
      if (children.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.child_care_outlined, size: 40.sp, color: _muted),
              SizedBox(height: 12.h),
              Text(
                'collection_directory_empty'.tr,
                textAlign: TextAlign.center,
                style: context.typography.smSemiBold
                    .copyWith(color: _ink, fontSize: 14.5),
              ),
            ],
          ),
        );
      }
      final canRenew = controller.monthlyPackage != null;
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        itemCount: children.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (_, i) {
          final c = children[i];
          return CollectionChildCard(
            child: c,
            subtitle: controller.classroomName(c.classroomId),
            canRenew: canRenew,
            onRenew: () => onRenew(c),
            onHistory: () => onHistory(c),
          );
        },
      );
    });
  }
}

/// Compact single-row child card used by both the directory list and the
/// search results: avatar + name/classroom + two trailing icon actions.
class CollectionChildCard extends StatelessWidget {
  final ChildModel child;
  final String subtitle;
  final bool canRenew;
  final VoidCallback onRenew;
  final VoidCallback onHistory;

  const CollectionChildCard({
    super.key,
    required this.child,
    required this.subtitle,
    required this.canRenew,
    required this.onRenew,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: child.hasImage
                ? AppNetworkImage(url: child.profileImage, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      child.firstName.isNotEmpty ? child.firstName[0] : '?',
                      style: context.typography.mdBold
                          .copyWith(color: _accent, fontSize: 17),
                    ),
                  ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: _ink, fontSize: 14),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular
                      .copyWith(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _IconAction(
            icon: Icons.receipt_long_rounded,
            tooltip: 'collection_history_title'.tr,
            filled: false,
            onTap: onHistory,
          ),
          if (canRenew) ...[
            SizedBox(width: 8.w),
            _IconAction(
              icon: Icons.autorenew_rounded,
              tooltip: 'collection_renew_subscription'.tr,
              filled: true,
              onTap: onRenew,
            ),
          ],
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool filled;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? _accent : _bg,
            borderRadius: BorderRadius.circular(12.r),
            border: filled ? null : Border.all(color: _line),
          ),
          child: Icon(
            icon,
            size: 19.sp,
            color: filled ? Colors.white : _accent,
          ),
        ),
      ),
    );
  }
}
