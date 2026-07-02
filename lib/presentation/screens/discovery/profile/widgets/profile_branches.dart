import '../../../../../index/index_main.dart';
import 'profile_packages.dart';

/// Vertical list of nursery branches. Each branch is a compact list-item card:
/// an avatar, the name + address, and small trailing action buttons
/// (directions / call) — no oversized full-width buttons.
class ProfileBranches extends StatelessWidget {
  final List<BranchView> branches;
  final void Function(BranchView) onDirections;
  final void Function(BranchView) onCall;
  final void Function(BranchView) onWhatsapp;

  const ProfileBranches({
    super.key,
    required this.branches,
    required this.onDirections,
    required this.onCall,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < branches.length; i++) ...[
          _BranchCard(
            branch: branches[i],
            onDirections: () => onDirections(branches[i]),
            onCall: () => onCall(branches[i]),
            onWhatsapp: () => onWhatsapp(branches[i]),
          ),
          if (i != branches.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchView branch;
  final VoidCallback onDirections;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  const _BranchCard({
    required this.branch,
    required this.onDirections,
    required this.onCall,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = (branch.phone ?? '').trim().isNotEmpty;
    final hasWhatsapp =
        (branch.whatsapp ?? '').trim().isNotEmpty || hasPhone;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(Icons.store_mall_directory_rounded,
                    size: 22.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: branch.name,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 1,
                    ),
                    if ((branch.address ?? '').isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13.sp, color: AppColors.primary60),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: AppText(
                              text: branch.address!,
                              textStyle: context.typography.xsRegular.copyWith(
                                color: AppColors.textSecondaryParagraph,
                                height: 1.4,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (branch.hasLocation || hasPhone || hasWhatsapp)
                SizedBox(width: 8.w),
              if (branch.hasLocation)
                _IconAction(
                  icon: Icons.directions_rounded,
                  color: AppColors.primary,
                  filled: false,
                  onTap: onDirections,
                ),
              if (hasPhone) ...[
                if (branch.hasLocation) SizedBox(width: 8.w),
                _IconAction(
                  icon: Icons.phone_rounded,
                  color: AppColors.primary,
                  filled: true,
                  onTap: onCall,
                ),
              ],
              if (hasWhatsapp) ...[
                if (branch.hasLocation || hasPhone) SizedBox(width: 8.w),
                _IconAction(
                  icon: Icons.chat_rounded,
                  color: AppColors.activityGreen,
                  filled: true,
                  onTap: onWhatsapp,
                ),
              ],
            ],
          ),
          if (branch.packages.isNotEmpty) ...[
            SizedBox(height: 12.h),
            BranchPackageList(packages: branch.packages),
          ],
        ],
      ),
    );
  }
}

/// Small square icon button. [filled] gives a solid CTA (white glyph);
/// otherwise a soft tinted button with a subtle border.
class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13.r),
          border:
              filled ? null : Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(
          icon,
          size: 21.sp,
          color: filled ? AppColors.white : color,
        ),
      ),
    );
  }
}
