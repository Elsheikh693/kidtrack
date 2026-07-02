import '../../../../../index/index_main.dart';
import 'password_field.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.controller,
    required this.formKey,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.bottomPad,
    required this.formAnim,
  });

  final LoginController controller;
  final GlobalKey<FormState> formKey;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final double bottomPad;
  final Animation<double> formAnim;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: formAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.07),
          end: Offset.zero,
        ).animate(formAnim),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36.r)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary80.withValues(alpha: 0.18),
                blurRadius: 48.r,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, bottomPad + 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Welcome heading
              Text(
                'customer_login_title'.tr,
                style: context.typography.xsBold.copyWith(
                  color: AppColors.textDisplay,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'customer_login_subtitle'.tr,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 30.h),

              // Email field
              _FieldLabel('login_field_email'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.emailController,
                focusNode: emailFocusNode,
                hintText: 'customer_login_phone_hint'.tr,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: controller.validateEmail,
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondaryParagraph,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'login_error_email_required'.tr;
                  final t = v.trim();
                  final isPhone = RegExp(r'^\d{9,15}$').hasMatch(t);
                  final isEmail = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(t);
                  if (!isPhone && !isEmail) return 'login_error_email_invalid'.tr;
                  return null;
                },
              ),

              SizedBox(height: 22.h),

              // Password field
              _FieldLabel('login_field_password'.tr),
              SizedBox(height: 8.h),
              LoginPasswordField(
                controller: controller.passwordController,
                focusNode: passwordFocusNode,
                loginController: controller,
              ),

              SizedBox(height: 36.h),

              // Submit button
              Obx(
                () {
                  final active = controller.canSubmit && !controller.isLoading.value;
                  return GestureDetector(
                    onTap: active
                        ? () {
                            FocusScope.of(context).unfocus();
                            if (formKey.currentState?.validate() ?? false) {
                              controller.login();
                            }
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: active
                            ? LinearGradient(
                                colors: [AppColors.primary60, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: active ? null : AppColors.primary.withValues(alpha: 0.28),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.40),
                                  blurRadius: 24.r,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : Text(
                                'customer_login_btn'.tr,
                                style: context.typography.mdBold.copyWith(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.typography.smSemiBold.copyWith(
          color: AppColors.textDisplay,
          fontSize: 14,
        ),
      );
}
