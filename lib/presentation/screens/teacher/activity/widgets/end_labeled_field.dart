import '../../../../../index/index_main.dart';

class EndLabeledField extends StatelessWidget {
  const EndLabeledField({
    super.key,
    required this.labelKey,
    required this.hintKey,
    required this.controller,
    required this.accentColor,
    this.maxLines = 1,
  });

  final String labelKey;
  final String hintKey;
  final TextEditingController controller;
  final Color accentColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr,
          style: context.typography.xsMedium
              .copyWith(color: AppColors.textPrimaryParagraph),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textDirection: appTextDirection,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintKey.tr,
            hintTextDirection: TextDirection.rtl,
            hintStyle: context.typography.xsRegular
                .copyWith(color: AppColors.grayMedium),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
