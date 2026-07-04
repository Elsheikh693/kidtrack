import '../../../../../index/index_main.dart';

/// Compose-and-send sheet for a subscription reminder. Pre-fills an editable
/// default message (personalised with the child's name) that staff can tweak
/// per family before sending to ALL of the child's linked guardians.
class SendReminderSheet extends StatefulWidget {
  const SendReminderSheet({
    super.key,
    required this.childName,
    required this.onSend,
  });

  final String childName;
  final ValueChanged<String> onSend;

  @override
  State<SendReminderSheet> createState() => _SendReminderSheetState();
}

class _SendReminderSheetState extends State<SendReminderSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: 'unpaid_reminder_default'.trParams({'name': widget.childName}),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      Loader.showError('unpaid_reminder_empty'.tr);
      return;
    }
    Get.back();
    widget.onSend(message);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          16.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.dividerAndLines,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'unpaid_reminder_sheet_title'.tr,
              style: context.typography.mdBold.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'unpaid_reminder_sheet_subtitle'.trParams({
                'name': widget.childName,
              }),
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.dividerAndLines.withValues(alpha: 0.6),
                ),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 3,
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textDefault,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'unpaid_reminder_hint'.tr,
                  hintStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            GestureDetector(
              onTap: _send,
              child: Container(
                height: 50.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 18.sp,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'unpaid_send'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
