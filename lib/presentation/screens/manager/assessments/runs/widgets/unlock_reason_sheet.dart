import '../../../../../../index/index_main.dart';

/// Bottom sheet that captures the required reason for unlocking a frozen result
/// (the audited correction path). Confirm is disabled until a reason is typed.
class UnlockReasonSheet extends StatefulWidget {
  final ValueChanged<String> onConfirm;
  const UnlockReasonSheet({super.key, required this.onConfirm});

  @override
  State<UnlockReasonSheet> createState() => _UnlockReasonSheetState();
}

class _UnlockReasonSheetState extends State<UnlockReasonSheet> {
  final _ctrl = TextEditingController();

  static const _accent = Color(0xFF6366F1);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('assessment_unlock_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text('assessment_unlock_hint'.tr,
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8))),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                  style: context.typography.smRegular,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'assessment_unlock_reason_hint'.tr,
                    hintStyle: context.typography.smRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ctrl.text.trim().isEmpty
                      ? null
                      : () => widget.onConfirm(_ctrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('assessment_action_unlock'.tr,
                      style: context.typography.smSemiBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
