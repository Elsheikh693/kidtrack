import '../../../../../index/index_main.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loginController,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppTextField(
        controller: controller,
        focusNode: focusNode,
        hintText: '••••••••',
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        obscureText: !loginController.showPassword.value,
        onChanged: loginController.validatePassword,
        suffixIcon: IconButton(
          icon: Icon(
            loginController.showPassword.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondaryParagraph,
            size: 20.sp,
          ),
          onPressed: loginController.togglePassword,
        ),
        validator: Validators.combine([
          (v) => Validators.notEmpty(
            v,
            errorMessage: 'login_error_password_required'.tr,
          ),
          (v) => (v != null && v.length >= 6)
              ? null
              : 'login_error_password_short'.tr,
        ]),
      ),
    );
  }
}
