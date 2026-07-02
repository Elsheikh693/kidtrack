import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_shared_widgets.dart';

class BranchInfoStep extends StatelessWidget {
  final ManagerSetupController controller;
  const BranchInfoStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.storefront_rounded,
                    color: const Color(0xFF5E35B1), size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('setup_step_branch'.tr,
                        style: context.typography.mdBold.copyWith(
                            fontSize: 17, color: const Color(0xFF1F2937))),
                    Text('setup_branch_step_subtitle'.tr,
                        style: context.typography.xsRegular.copyWith(
                            fontSize: 12, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          SetupSheetLabel('setup_branch_name_label'.tr),
          SizedBox(height: 6.h),
          SetupSheetField(
            controller: controller.branchNameCtrl,
            hint: 'setup_branch_name_hint'.tr,
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16.sp, color: const Color(0xFF9CA3AF)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text('setup_branch_name_note'.tr,
                    style: context.typography.xsRegular.copyWith(
                        fontSize: 12, color: const Color(0xFF9CA3AF))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
