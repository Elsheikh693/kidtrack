import '../../../../../index/index_main.dart';

class NurseryOwnerSection extends StatelessWidget {
  final TextEditingController ownerNameCtrl;
  final TextEditingController ownerPhoneCtrl;

  const NurseryOwnerSection({
    super.key,
    required this.ownerNameCtrl,
    required this.ownerPhoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        _NurseryLabel('nursery_owner_name_label'.tr),
        SizedBox(height: 6.h),
        _NurseryField(
          controller: ownerNameCtrl,
          hint: 'nursery_owner_name_hint'.tr,
        ),
        SizedBox(height: 14.h),
        _NurseryLabel('nursery_owner_phone_label'.tr),
        SizedBox(height: 6.h),
        _NurseryField(
          controller: ownerPhoneCtrl,
          hint: 'nursery_owner_phone_hint'.tr,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 6.h),
        Text(
          'nursery_owner_password_note'.tr,
          style: context.typography.xsRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _NurseryLabel extends StatelessWidget {
  final String text;
  const _NurseryLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.smMedium.copyWith(
      fontSize: 14,
      color: const Color(0xFF475569),
    ),
  );
}

class _NurseryField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _NurseryField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: controller,
    keyboardType: keyboardType,
    style: context.typography.smRegular.copyWith(
      color: const Color(0xFF1E293B),
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(
        color: const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
