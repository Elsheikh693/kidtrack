import '../../../../../index/index_main.dart';

class HomeworkTextField extends StatelessWidget {
  const HomeworkTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.maxLines = 1,
    this.accentColor,
  });
  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final int maxLines;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.activityAmberBrand;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      style: context.typography.smRegular,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.typography.smRegular
            .copyWith(color: AppColors.textFieldPlaceholder),
        filled: true,
        fillColor: AppColors.backgroundNeutralDefault,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}
