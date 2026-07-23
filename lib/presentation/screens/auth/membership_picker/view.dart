import '../../../../index/index_main.dart';
import 'widgets/membership_card.dart';

/// Post-login role picker — shown when one identity holds several memberships.
class MembershipPickerView extends StatefulWidget {
  const MembershipPickerView({super.key});

  @override
  State<MembershipPickerView> createState() => _MembershipPickerViewState();
}

class _MembershipPickerViewState extends State<MembershipPickerView> {
  late final MembershipPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MembershipPickerController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.canCancel)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, size: 24.sp),
                    color: AppColors.textSecondaryParagraph,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              AppText(
                text: 'membership_pick_title'.tr,
                textStyle: context.typography.xlBold,
              ),
              SizedBox(height: 8.h),
              Obx(
                () => AppText(
                  text: 'membership_pick_subtitle'.trParams({
                    'name': controller.displayName,
                  }),
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: controller.options.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) => MembershipCard(
                      controller: controller,
                      membership: controller.options[i],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
