import '../../../../../index/index_main.dart';

/// Editable list of free-text "what did you like?" choices for a campaign.
/// Manages its own working list and reports every change up via [onChanged].
class CampaignTagsField extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;

  const CampaignTagsField({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<CampaignTagsField> createState() => _CampaignTagsFieldState();
}

class _CampaignTagsFieldState extends State<CampaignTagsField> {
  late final List<String> _tags = [...widget.initial];
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final value = _ctrl.text.trim();
    if (value.isEmpty || _tags.contains(value)) {
      _ctrl.clear();
      return;
    }
    setState(() {
      _tags.add(value);
      _ctrl.clear();
    });
    widget.onChanged(_tags);
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sa_feedback_tags_label'.tr,
          style: context.typography.xsMedium
              .copyWith(color: const Color(0xFF374151)),
        ),
        SizedBox(height: 4.h),
        Text(
          'sa_feedback_tags_hint'.tr,
          style: context.typography.xsRegular
              .copyWith(fontSize: 11, color: const Color(0xFF94A3B8)),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: 'sa_feedback_tags_field_hint'.tr,
                  hintStyle: context.typography.xsRegular
                      .copyWith(fontSize: 13, color: const Color(0xFF94A3B8)),
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
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: _add,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _tags
                .map((t) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t,
                            style: context.typography.xsMedium
                                .copyWith(color: AppColors.primary),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => _remove(t),
                            child: Icon(Icons.close,
                                size: 15.sp, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
