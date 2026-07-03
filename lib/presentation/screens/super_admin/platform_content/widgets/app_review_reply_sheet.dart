import '../../../../../index/index_main.dart';

class AppReviewReplySheet extends StatefulWidget {
  final AppReviewsAdminController controller;
  final AppReviewModel item;

  const AppReviewReplySheet({
    super.key,
    required this.controller,
    required this.item,
  });

  @override
  State<AppReviewReplySheet> createState() => _AppReviewReplySheetState();
}

class _AppReviewReplySheetState extends State<AppReviewReplySheet> {
  late final TextEditingController _replyCtrl;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController(text: widget.item.adminReply ?? '');
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    await widget.controller.saveReply(widget.item, reply: _replyCtrl.text);
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final name = (widget.item.name ?? '').isEmpty
        ? 'arv_anonymous'.tr
        : widget.item.name!;
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
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < widget.item.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.ratingStar,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if ((widget.item.comment ?? '').isNotEmpty)
                Text(
                  widget.item.comment!,
                  style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph, height: 1.6),
                ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 16.sp, color: AppColors.grayMedium),
                  SizedBox(width: 8.w),
                  Text(
                    name,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textDefault),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'arv_reply_label'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: _replyCtrl,
                hintText: 'arv_reply_hint'.tr,
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
                    text: 'arv_save'.tr,
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
