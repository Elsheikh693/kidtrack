import '../../../../../index/index_main.dart';

class DiscoveryNurseryCard extends StatelessWidget {
  final NurseryModel nursery;
  final VoidCallback onTap;
  final VoidCallback onApply;

  const DiscoveryNurseryCard({
    super.key,
    required this.nursery,
    required this.onTap,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final tags = nursery.programs;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary80.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cover(context),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: nursery.name,
                  textStyle: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                ),
                _statsRow(context),
                if ((nursery.address ?? '').isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 15.sp, color: AppColors.primary60),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: AppText(
                          text: nursery.address!,
                          textStyle: context.typography.xsRegular
                              .copyWith(color: AppColors.textSecondaryParagraph),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                if ((nursery.description ?? '').isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  AppText(
                    text: nursery.description!,
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                      height: 1.5,
                    ),
                    maxLines: 2,
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: tags.map((t) => _Tag(text: t)).toList(),
                  ),
                ],
                SizedBox(height: 16.h),
                _detailsButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Always renders something under the name so the card never looks empty —
  /// real metrics when present, a friendly "new nursery" line otherwise.
  Widget _statsRow(BuildContext context) {
    final chips = <Widget>[];

    if (nursery.rating != null) {
      chips.add(_InfoChip(
        icon: Icons.star_rounded,
        iconColor: AppColors.yellowForeground,
        label: nursery.rating!.toStringAsFixed(1),
      ));
    }
    if ((nursery.childrenCount ?? 0) > 0) {
      chips.add(_InfoChip(
        icon: Icons.child_care_rounded,
        iconColor: AppColors.primary60,
        label: 'discovery_children_count'
            .trParams({'count': '${nursery.childrenCount}'}),
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: chips,
      ),
    );
  }

  Widget _cover(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          child: AppNetworkImage(
            url: nursery.coverPhoto ?? nursery.logo,
            width: double.infinity,
            height: 168.h,
            errorWidget: Container(
              width: double.infinity,
              height: 168.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary20,
                  ],
                ),
              ),
              child: Icon(Icons.home_work_rounded,
                  size: 48.sp, color: AppColors.primary40),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.28),
                ],
              ),
            ),
          ),
        ),
        if (nursery.rating != null)
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      size: 15.sp, color: AppColors.yellowForeground),
                  SizedBox(width: 3.w),
                  AppText(
                    text: nursery.rating!.toStringAsFixed(1),
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _detailsButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryTextButton(
            appButtonSize: AppButtonSize.large,
            onTap: onApply,
            leading: (c) =>
                Icon(Icons.app_registration_rounded, size: 18.sp, color: c),
            label: AppText(
              text: 'apply_online_btn'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: AppText(
              text: 'discovery_view_details'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: iconColor),
          SizedBox(width: 4.w),
          AppText(
            text: label,
            textStyle: context.typography.xsMedium
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: AppText(
        text: text,
        textStyle:
            context.typography.xsMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
