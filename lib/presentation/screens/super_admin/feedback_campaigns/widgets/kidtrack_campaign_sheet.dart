import '../../../../../index/index_main.dart';
import 'campaign_tags_field.dart';

class KidtrackCampaignSheet extends StatefulWidget {
  final KidtrackFeedbackCampaignModel? existing;
  const KidtrackCampaignSheet({super.key, this.existing});

  @override
  State<KidtrackCampaignSheet> createState() => _KidtrackCampaignSheetState();
}

class _KidtrackCampaignSheetState extends State<KidtrackCampaignSheet>
    with KeyboardSheetMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _enabled = true;
  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.existing?.title ?? '';
    _descCtrl.text = widget.existing?.description ?? '';
    _enabled = widget.existing?.enabled ?? true;
    _tags = [...?widget.existing?.tags];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Loader.showError('sa_feedback_title_required'.tr);
      return;
    }
    final desc = _descCtrl.text.trim();
    final isNew = widget.existing == null;
    final service = Get.find<KidtrackCampaignService>();

    Loader.show();
    try {
      if (isNew) {
        await service.create(
          KidtrackFeedbackCampaignModel(
            title: title,
            description: desc.isEmpty ? null : desc,
            enabled: _enabled,
            tags: _tags,
          ),
        );
      } else {
        await service.update(
          widget.existing!.copyWith(
            title: title,
            description: desc.isEmpty ? null : desc,
            enabled: _enabled,
            tags: _tags,
          ),
        );
      }
      Loader.dismiss();
      Loader.showSuccess(
          isNew ? 'sa_feedback_saved'.tr : 'sa_feedback_updated'.tr);
      Get.back();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                widget.existing == null
                    ? 'sa_feedback_add'.tr
                    : 'sa_feedback_edit'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),
              Text(
                'sa_feedback_title_label'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              _field(context, _titleCtrl, 'sa_feedback_title_hint'.tr),
              SizedBox(height: 16.h),
              Text(
                'sa_feedback_desc_label'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              _field(context, _descCtrl, 'sa_feedback_desc_hint'.tr,
                  maxLines: 3),
              SizedBox(height: 16.h),
              CampaignTagsField(
                initial: _tags,
                onChanged: (t) => _tags = t,
              ),
              SizedBox(height: 16.h),
              _enabledSwitch(context),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    widget.existing == null
                        ? 'sa_feedback_save'.tr
                        : 'sa_feedback_update'.tr,
                    style: context.typography.smSemiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      textInputAction:
          maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  Widget _enabledSwitch(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'sa_feedback_enabled_label'.tr,
              style: context.typography.smMedium
                  .copyWith(color: const Color(0xFF374151)),
            ),
          ),
          Switch(
            value: _enabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}
