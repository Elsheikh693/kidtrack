import '../../../../../index/index_main.dart';

class SupportTicketSheet extends StatefulWidget {
  final SupportTicketModel? existing;
  final String nurseryId;
  final String submittedBy;
  final bool isReplyMode;

  const SupportTicketSheet({super.key, this.existing, required this.nurseryId, required this.submittedBy, this.isReplyMode = false});

  @override
  State<SupportTicketSheet> createState() => _SupportTicketSheetState();
}

class _SupportTicketSheetState extends State<SupportTicketSheet> with KeyboardSheetMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _replyCtrl = TextEditingController();
  late String _status;

  static const _statuses = ['open', 'in_progress', 'resolved', 'closed'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _descCtrl.text = e?.description ?? '';
    _replyCtrl.text = e?.adminReply ?? '';
    _status = e?.status ?? 'open';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isReplyMode) {
      Get.back(result: {'reply': _replyCtrl.text.trim(), 'status': _status});
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) return;
    final model = SupportTicketModel(
      key: widget.existing?.key,
      nurseryId: widget.nurseryId,
      submittedBy: widget.submittedBy,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: _status,
      adminReply: _replyCtrl.text.trim().isEmpty ? null : _replyCtrl.text.trim(),
      createdAt: widget.existing?.createdAt,
    );
    Get.back(result: model);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.isReplyMode ? 'ticket_reply_title'.tr : (widget.existing == null ? 'ticket_add'.tr : 'ticket_edit'.tr),
              style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 20.h),
            if (!widget.isReplyMode) ...[
              TextFormField(controller: _titleCtrl, decoration: _decoration('ticket_title'.tr)),
              SizedBox(height: 14.h),
              TextFormField(controller: _descCtrl, decoration: _decoration('ticket_description'.tr), maxLines: 4),
              SizedBox(height: 14.h),
            ],
            if (widget.isReplyMode || widget.existing != null) ...[
              TextFormField(controller: _replyCtrl, decoration: _decoration('ticket_admin_reply'.tr), maxLines: 3),
              SizedBox(height: 14.h),
              Text('ticket_status_label'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 13, color: const Color(0xFF374151))),
              SizedBox(height: 8.h),
              Wrap(spacing: 8.w, runSpacing: 8.h, children: _statuses.map((s) {
                final active = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: active ? AppColors.primary : const Color(0xFFE2E8F0))),
                    child: Text('ticket_status_$s'.tr, style: context.typography.xsMedium.copyWith(fontSize: 12, color: active ? Colors.white : const Color(0xFF475569))),
                  ),
                );
              }).toList()),
              SizedBox(height: 14.h),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                child: Text(widget.isReplyMode ? 'ticket_send_reply'.tr : (widget.existing == null ? 'ticket_save'.tr : 'ticket_update'.tr), style: context.typography.smSemiBold.copyWith(fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF94A3B8)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.primary)),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
  );
}
