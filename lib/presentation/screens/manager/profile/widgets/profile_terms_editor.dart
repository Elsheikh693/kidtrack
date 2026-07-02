import '../../../../../index/index_main.dart';

/// Add-one-at-a-time editor for terms & conditions. Unlike the tag editor
/// (short pills in a Wrap), each clause is a full sentence, so added clauses
/// are listed vertically — numbered, stacked one under the other — each with
/// its own delete button.
class ProfileTermsEditor extends StatefulWidget {
  const ProfileTermsEditor({
    super.key,
    required this.hint,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });

  final String hint;
  final RxList<String> items;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  @override
  State<ProfileTermsEditor> createState() => _ProfileTermsEditorState();
}

class _ProfileTermsEditorState extends State<ProfileTermsEditor> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 3,
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.add_rounded, color: AppColors.white),
              ),
            ),
          ],
        ),
        Obx(() {
          if (widget.items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Column(
              children: [
                for (int i = 0; i < widget.items.length; i++) ...[
                  _TermRow(
                    index: i + 1,
                    text: widget.items[i],
                    onRemove: () => widget.onRemove(widget.items[i]),
                  ),
                  if (i != widget.items.length - 1) SizedBox(height: 8.h),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({
    required this.index,
    required this.text,
    required this.onRemove,
  });

  final int index;
  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 22.w),
            height: 22.w,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppText(
              text: '$index',
              textStyle: context.typography.xsBold
                  .copyWith(color: AppColors.primary, fontSize: 11.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: text,
              textStyle: context.typography.smRegular.copyWith(
                color: AppColors.textDefault,
                height: 1.6,
              ),
              maxLines: 10,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 18.r, color: AppColors.errorForeground),
          ),
        ],
      ),
    );
  }
}
