import '../../../../index/index_main.dart';
import 'reception_collection_controller.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);
const _bg = Color(0xFFF6F7FB);

/// Default reception "الماليات" state: the whole in-scope children directory
/// with two quick actions per child — one-tap "renew monthly subscription" and
/// "other payments" (which drops into the same per-child collection view the
/// search flow opens).
class ReceptionDirectoryList extends StatelessWidget {
  final ReceptionCollectionController controller;
  final ValueChanged<ChildModel> onOtherPayments;
  final ValueChanged<ChildModel> onRenew;

  const ReceptionDirectoryList({
    super.key,
    required this.controller,
    required this.onOtherPayments,
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
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, i) {
          final c = children[i];
          return _DirectoryCard(
            child: c,
            subtitle: controller.classroomName(c.classroomId),
            canRenew: canRenew,
            onRenew: () => onRenew(c),
            onOther: () => onOtherPayments(c),
          );
        },
      );
    });
  }
}

class _DirectoryCard extends StatelessWidget {
  final ChildModel child;
  final String subtitle;
  final bool canRenew;
  final VoidCallback onRenew;
  final VoidCallback onOther;

  const _DirectoryCard({
    required this.child,
    required this.subtitle,
    required this.canRenew,
    required this.onRenew,
    required this.onOther,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
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
                              .copyWith(color: _accent, fontSize: 18),
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: context.typography.smSemiBold
                          .copyWith(color: _ink, fontSize: 14.5),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: context.typography.xsRegular
                          .copyWith(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (canRenew) ...[
                Expanded(
                  child: _ActionButton(
                    label: 'collection_renew_subscription'.tr,
                    icon: Icons.autorenew_rounded,
                    filled: true,
                    onTap: onRenew,
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: _ActionButton(
                  label: 'collection_other_payments'.tr,
                  icon: Icons.receipt_long_rounded,
                  filled: false,
                  onTap: onOther,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? _accent : _bg,
          borderRadius: BorderRadius.circular(12.r),
          border: filled ? null : Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16.sp, color: filled ? Colors.white : _accent),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsMedium.copyWith(
                  color: filled ? Colors.white : _accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
