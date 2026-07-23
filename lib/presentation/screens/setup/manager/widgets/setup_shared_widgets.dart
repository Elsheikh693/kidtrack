import '../../../../../index/index_main.dart';

// ── Step scaffold used by all manager setup steps ─────────────────────────────

class SetupStepScaffold extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final String addLabel;
  final IconData emptyIcon;
  final String emptyLabel;
  final List<Widget> items;

  const SetupStepScaffold({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    required this.addLabel,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: context.typography.mdBold.copyWith(
                                  fontSize: 17,
                                  color: const Color(0xFF1F2937))),
                          Text(subtitle,
                              style: context.typography.xsRegular.copyWith(
                                  fontSize: 12, color: const Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onAdd,
                      icon: Icon(Icons.add_rounded, size: 16.sp),
                      label: Text(addLabel,
                          style: context.typography.xsRegular
                              .copyWith(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                if (items.isEmpty)
                  SetupEmptyState(icon: emptyIcon, label: emptyLabel)
                else
                  ...items,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class SetupEmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const SetupEmptyState({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(icon, size: 52.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 12.h),
              Text(label,
                  style: context.typography.smSemiBold.copyWith(
                      fontSize: 14, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
}

// ── Simple add sheet ──────────────────────────────────────────────────────────

class SetupSimpleSheet extends StatelessWidget {
  final String title;
  final TextEditingController nameCtrl;
  final String nameLabel;
  final String nameHint;
  final TextEditingController? extraCtrl;
  final String? extraLabel;
  final String? extraHint;
  final VoidCallback onSubmit;

  const SetupSimpleSheet({
    super.key,
    required this.title,
    required this.nameCtrl,
    required this.nameLabel,
    required this.nameHint,
    this.extraCtrl,
    this.extraLabel,
    this.extraHint,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(title,
                  style: context.typography.mdBold
                      .copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),
              SetupSheetLabel(nameLabel),
              SizedBox(height: 6.h),
              SetupSheetField(controller: nameCtrl, hint: nameHint),
              if (extraCtrl != null) ...[
                SizedBox(height: 16.h),
                SetupSheetLabel(extraLabel!),
                SizedBox(height: 6.h),
                SetupSheetField(
                    controller: extraCtrl!, hint: extraHint ?? ''),
              ],
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text('setup_add_btn'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sheet helpers ─────────────────────────────────────────────────────────────

class SetupSheetLabel extends StatelessWidget {
  final String text;
  const SetupSheetLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text,
      style: context.typography.smMedium
          .copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class SetupSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const SetupSheetField(
      {super.key,
      required this.controller,
      required this.hint,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: const [EnglishDigitsFormatter()],
        style: context.typography.smRegular
            .copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.typography.smRegular
              .copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
            borderSide:
                const BorderSide(color: Color(0xFF5E35B1), width: 1.5),
          ),
        ),
      );
}
