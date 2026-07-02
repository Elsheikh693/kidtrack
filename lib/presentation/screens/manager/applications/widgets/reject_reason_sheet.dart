import '../../../../../index/index_main.dart';

class RejectReasonSheet extends StatefulWidget {
  final ValueChanged<String> onConfirm;
  const RejectReasonSheet({super.key, required this.onConfirm});

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w,
          18.h + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'apply_reject_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 14.h),
          AppTextField(
            controller: _reason,
            labelText: 'apply_reject_reason'.tr,
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          PrimaryTextButton(
            appButtonSize: AppButtonSize.xlarge,
            onTap: () {
              final reason = _reason.text.trim();
              if (reason.isEmpty) {
                Loader.showError('apply_err_reject_reason'.tr);
                return;
              }
              widget.onConfirm(reason);
            },
            customBackgroundColor: AppColors.activityRed,
            label: AppText(
              text: 'apply_reject_btn'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
