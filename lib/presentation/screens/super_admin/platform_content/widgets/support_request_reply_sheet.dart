import '../../../../../index/index_main.dart';

class SupportRequestReplySheet extends StatefulWidget {
  final SupportRequestsAdminController controller;
  final SupportRequestModel item;

  const SupportRequestReplySheet({
    super.key,
    required this.controller,
    required this.item,
  });

  @override
  State<SupportRequestReplySheet> createState() =>
      _SupportRequestReplySheetState();
}

class _SupportRequestReplySheetState extends State<SupportRequestReplySheet> {
  late final TextEditingController _replyCtrl;
  late String _status;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController(text: widget.item.adminReply ?? '');
    _status = widget.item.status;
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    await widget.controller.saveReply(
      widget.item,
      status: _status,
      reply: _replyCtrl.text,
    );
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                widget.item.subject,
                style: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.item.message,
                style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph, height: 1.6),
              ),
              SizedBox(height: 12.h),
              _ContactRow(
                  icon: Icons.person_outline_rounded, value: widget.item.name),
              _ContactRow(
                  icon: Icons.phone_outlined, value: widget.item.phone),
              if ((widget.item.email ?? '').isNotEmpty)
                _ContactRow(
                    icon: Icons.email_outlined, value: widget.item.email!),
              SizedBox(height: 20.h),
              Text(
                'srq_status_label'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                children: SupportRequestsAdminController.statuses.map((s) {
                  final selected = _status == s;
                  return GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.backgroundNeutral100,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.grayLight,
                        ),
                      ),
                      child: Text(
                        'srq_status_$s'.tr,
                        style: context.typography.xsMedium.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              Text(
                'srq_reply_label'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: _replyCtrl,
                hintText: 'srq_reply_hint'.tr,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 4,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryTextButton(
                  appButtonSize: AppButtonSize.xxLarge,
                  onTap: _save,
                  label: AppText(
                    text: 'srq_save'.tr,
                    textStyle: context.typography.mdBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.grayMedium),
          SizedBox(width: 8.w),
          Text(
            value,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}
