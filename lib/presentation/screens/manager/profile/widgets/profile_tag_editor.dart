import '../../../../../index/index_main.dart';

class ProfileTagEditor extends StatefulWidget {
  const ProfileTagEditor({
    super.key,
    required this.hint,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.color,
  });

  final String hint;
  final RxList<String> items;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final Color color;

  @override
  State<ProfileTagEditor> createState() => _ProfileTagEditorState();
}

class _ProfileTagEditorState extends State<ProfileTagEditor> {
  final _ctrl = TextEditingController();

  void _submit() {
    widget.onAdd(_ctrl.text);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: context.typography.smRegular.copyWith(
                      color: AppColors.grayMedium, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.add_rounded, color: AppColors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.items
                .map((tag) => _TagChip(
                      label: tag,
                      color: widget.color,
                      onRemove: () => widget.onRemove(tag),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  final String label;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            textStyle: context.typography.xsMedium.copyWith(color: color),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16.r, color: color),
          ),
        ],
      ),
    );
  }
}
