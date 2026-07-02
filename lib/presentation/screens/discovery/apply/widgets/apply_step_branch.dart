import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

class ApplyStepBranch extends StatelessWidget {
  final OnlineApplicationController controller;
  const ApplyStepBranch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCatalog.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          const ApplyStepHeader(
            icon: Icons.account_tree_rounded,
            titleKey: 'apply_step_branch_title',
            subtitleKey: 'apply_step_branch_sub',
          ),
          if (controller.branches.isEmpty)
            _empty(context, 'apply_branches_empty')
          else
            ...controller.branches.map((b) => _branchTile(context, b)),
          SizedBox(height: 18.h),
          if (controller.selectedBranchId.value != null) ...[
            _sectionLabel(context, 'apply_packages_label'),
            SizedBox(height: 10.h),
            if (controller.branchPackages.isEmpty)
              _empty(context, 'apply_packages_empty')
            else if (controller.branchPackages.length == 1)
              _packageDisplay(context, controller.branchPackages.first)
            else
              ...controller.branchPackages.map((p) => _packageTile(context, p)),
            SizedBox(height: 12.h),
            _totalBar(context),
          ],
          SizedBox(height: 20.h),
        ],
      );
    });
  }

  Widget _branchTile(BuildContext context, BranchModel branch) {
    final isSel = controller.selectedBranchId.value == branch.key;
    return GestureDetector(
      onTap: () => controller.selectBranch(branch),
      child: Container(
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? AppColors.primary : AppColors.grayLight,
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSel
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSel ? AppColors.primary : AppColors.grayMedium,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: branch.name,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  if ((branch.address ?? '').isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    AppText(
                      text: branch.address!,
                      textStyle: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph),
                      maxLines: 2,
                    ),
                  ],
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13.sp, color: AppColors.primary60),
                      SizedBox(width: 4.w),
                      AppText(
                        text: _distanceText(branch),
                        textStyle: context.typography.xsMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packageTile(BuildContext context, PackageModel pkg) {
    final isSel = controller.selectedPackageIds.contains(pkg.key);
    return GestureDetector(
      onTap: () => controller.togglePackage(pkg.key ?? ''),
      child: Container(
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? AppColors.primary : AppColors.grayLight,
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSel
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: isSel ? AppColors.primary : AppColors.grayMedium,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: pkg.name,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  SizedBox(height: 3.h),
                  AppText(
                    text: _durationLabel(pkg.duration),
                    textStyle: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AppText(
              text: '${_money(pkg.price)} ${'currency'.tr}',
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: 'apply_total_label'.tr,
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.white),
          ),
          AppText(
            text: '${_money(controller.selectedTotal)} ${'currency'.tr}',
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String key) {
    return AppText(
      text: key.tr,
      textStyle: context.typography.smSemiBold
          .copyWith(color: AppColors.textDefault),
    );
  }

  /// Single package: auto-included and shown for display only (no checkbox).
  Widget _packageDisplay(BuildContext context, PackageModel pkg) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: pkg.name,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 3.h),
                AppText(
                  text: _durationLabel(pkg.duration),
                  textStyle: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          AppText(
            text: '${_money(pkg.price)} ${'currency'.tr}',
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Approximate distance shown to the parent (placeholder until real
  /// geolocation is wired up). Stable per branch so it doesn't flicker.
  String _distanceText(BranchModel branch) {
    final seed = (branch.key ?? branch.name).hashCode.abs();
    final km = 1.0 + (seed % 90) / 10.0; // 1.0 – 9.9 km
    return '${km.toStringAsFixed(1)} ${'apply_distance_unit'.tr}';
  }

  Widget _empty(BuildContext context, String key) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grayLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: key.tr,
        textStyle: context.typography.xsRegular
            .copyWith(color: AppColors.textSecondaryParagraph),
        maxLines: 3,
      ),
    );
  }

  String _durationLabel(String duration) {
    switch (duration) {
      case 'term':
        return 'package_duration_term'.tr;
      case 'yearly':
        return 'package_duration_yearly'.tr;
      case 'oneTime':
        return 'package_duration_oneTime'.tr;
      default:
        return 'package_duration_monthly'.tr;
    }
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
