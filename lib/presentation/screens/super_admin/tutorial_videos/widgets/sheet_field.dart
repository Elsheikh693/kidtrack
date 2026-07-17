import '../../../../../index/index_main.dart';

/// Labelled text field used across the tutorial-video add/edit sheet.
class SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const SheetField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          textStyle: context.typography.xsMedium
              .copyWith(color: AppColors.textDefault),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: context.typography.smRegular
              .copyWith(color: AppColors.textDefault),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.typography.xsRegular
                .copyWith(color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
