import '../../../../index/index_main.dart';
import 'widgets/activation_code_card.dart';

class ActivationCodeView extends StatefulWidget {
  const ActivationCodeView({super.key});

  @override
  State<ActivationCodeView> createState() => _ActivationCodeViewState();
}

class _ActivationCodeViewState extends State<ActivationCodeView> {
  late final ActivationCodeController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ActivationCodeController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20.sp, color: AppColors.textDisplay),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(Icons.vpn_key_rounded,
                    color: AppColors.primary, size: 30.sp),
              ),
              SizedBox(height: 22.h),
              Text(
                'activation_screen_title'.tr,
                style: context.typography.xsBold.copyWith(
                  color: AppColors.textDisplay,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'activation_screen_sub'.tr,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 34.h),
              ActivationCodeCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
