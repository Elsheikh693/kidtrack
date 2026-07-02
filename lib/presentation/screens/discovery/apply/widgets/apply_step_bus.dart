import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

/// Optional bus-subscription step. A toggle opts the family in; when enabled a
/// detailed pickup address (pre-seeded from the child's address) is required.
class ApplyStepBus extends StatefulWidget {
  final OnlineApplicationController controller;
  const ApplyStepBus({super.key, required this.controller});

  @override
  State<ApplyStepBus> createState() => _ApplyStepBusState();
}

class _ApplyStepBusState extends State<ApplyStepBus> with KeyboardSheetMixin {
  late final FocusNode _addressFocus;

  @override
  void initState() {
    super.initState();
    _addressFocus = kbNode();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return wrapWithKeyboard(
      context: context,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          const ApplyStepHeader(
            icon: Icons.directions_bus_rounded,
            titleKey: 'apply_step_bus_title',
            subtitleKey: 'apply_step_bus_sub',
          ),
          _toggle(context, controller),
          Obx(() {
            if (!controller.wantsBus.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                ApplyField(
                  controller: controller.busAddress,
                  labelKey: 'apply_bus_address',
                  maxLines: 3,
                  focusNode: _addressFocus,
                ),
                _hint(context),
              ],
            );
          }),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _toggle(BuildContext context, OnlineApplicationController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_bus_rounded,
              size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: 'apply_bus_toggle'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDefault),
              maxLines: 2,
            ),
          ),
          Obx(() => Switch.adaptive(
                value: controller.wantsBus.value,
                activeThumbColor: AppColors.primary,
                onChanged: controller.toggleBus,
              )),
        ],
      ),
    );
  }

  Widget _hint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              text: 'apply_bus_hint'.tr,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.primary, height: 1.6),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }
}
