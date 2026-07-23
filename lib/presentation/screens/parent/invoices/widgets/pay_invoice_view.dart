import 'dart:io';
import '../../../../../index/index_main.dart';

const _purple = Color(0xFF6D4AFF);
const _green = Color(0xFF16A34A);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _line = Color(0xFFEEF0F4);
const _bg = Color(0xFFF6F7FB);

/// Full-screen guardian pay flow for one outstanding invoice: the amount due,
/// the nursery's collection accounts (each clearly tagged InstaPay / wallet with
/// a copy button and — for InstaPay — a big "open link & pay" action), then a
/// transfer-screenshot upload. The screenshot is stamped onto the invoice
/// ([InvoiceModel.proofUrl]); reception/CS reviews it and records the collection.
class PayInvoiceView extends StatefulWidget {
  final InvoiceModel invoice;
  final List<PaymentAccountModel> accounts;

  const PayInvoiceView({
    super.key,
    required this.invoice,
    required this.accounts,
  });

  @override
  State<PayInvoiceView> createState() => _PayInvoiceViewState();
}

class _PayInvoiceViewState extends State<PayInvoiceView> {
  File? _proof;
  bool _uploading = false;
  late String? _existingProof;

  @override
  void initState() {
    super.initState();
    _existingProof = widget.invoice.proofUrl;
  }

  Future<void> _pick() async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file != null) setState(() => _proof = file);
    });
  }

  Future<void> _submit() async {
    if (_proof == null) {
      Loader.showError('pay_invoice_proof_required'.tr);
      return;
    }
    setState(() => _uploading = true);
    final invoice = widget.invoice;
    final credentials = Get.find<FirebaseCredentialsService>();
    final key =
        'paymentProofs/${invoice.nurseryId}/${invoice.key}/${DateTime.now().millisecondsSinceEpoch}';

    final uploaded = await credentials.uploadImage(key, _proof!);
    final url = uploaded.fold((_) => null, (u) => u);
    if (url == null) {
      setState(() => _uploading = false);
      Loader.showError('pay_invoice_submit_error'.tr);
      return;
    }

    final updated = invoice.copyWith(
      proofUrl: url,
      proofSubmittedAt: DateTime.now().millisecondsSinceEpoch,
    );
    Get.find<InvoiceParentService>().update(
      item: updated,
      callBack: (status) {
        setState(() => _uploading = false);
        if (status == ResponseStatus.success) {
          Loader.showSuccess('pay_invoice_submitted'.tr);
          Get.back();
        } else {
          Loader.showError('pay_invoice_submit_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final hasAccounts = widget.accounts.isNotEmpty;
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_ios_rounded, color: _ink, size: 20.sp),
          ),
          title: Text(
            'pay_invoice_title'.tr,
            style: context.typography.mdBold.copyWith(color: _ink),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            _AmountCard(invoice: invoice),
            SizedBox(height: 22.h),
            Text(
              'pay_invoice_accounts_title'.tr,
              style: context.typography.smSemiBold.copyWith(color: _ink),
            ),
            SizedBox(height: 12.h),
            if (!hasAccounts)
              _NoAccounts()
            else
              ...widget.accounts.map((a) => _AccountCard(account: a)),
            SizedBox(height: 22.h),
            Text(
              'pay_invoice_upload_proof'.tr,
              style: context.typography.smSemiBold.copyWith(color: _ink),
            ),
            SizedBox(height: 12.h),
            _ProofBox(
              picked: _proof,
              existingUrl: _existingProof,
              onTap: _uploading ? null : _pick,
            ),
            if (_existingProof != null && _proof == null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 14.sp, color: const Color(0xFFD97706)),
                  SizedBox(width: 6.w),
                  Text(
                    'pay_invoice_proof_pending'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFFD97706)),
                  ),
                ],
              ),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _uploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _uploading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'pay_invoice_submit'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Amount due ────────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _AmountCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final title = [invoice.categoryName, invoice.title]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' • ');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, Color(0xFF9D5CF0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.28),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'parent_pay_remaining'.tr,
            style: context.typography.xsMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                invoice.remaining.toStringAsFixed(0),
                style: context.typography.xxlBold
                    .copyWith(color: Colors.white, height: 1),
              ),
              SizedBox(width: 6.w),
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Text(
                  'currency'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
            ],
          ),
          if (title.isNotEmpty || invoice.dueDate != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                if (title.isNotEmpty)
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xsRegular
                          .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                if (invoice.dueDate != null) ...[
                  if (title.isNotEmpty)
                    Text('  •  ',
                        style: context.typography.xsRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  Icon(Icons.calendar_today_rounded,
                      size: 12.sp, color: Colors.white.withValues(alpha: 0.9)),
                  SizedBox(width: 4.w),
                  Text(
                    _fmt(invoice.dueDate!),
                    style: context.typography.xsRegular
                        .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ── Account card ──────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final PaymentAccountModel account;
  const _AccountCard({required this.account});

  Future<void> _open() async {
    var n = account.link.trim();
    if (n.isEmpty) return;
    if (!n.startsWith('http')) n = 'https://$n';
    final uri = Uri.tryParse(n);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('pay_open_error'.tr);
    }
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: account.number));
    Loader.showSuccess('pay_copied'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final instapay = account.isInstapay;
    final color = instapay ? _purple : _green;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  instapay
                      ? Icons.qr_code_rounded
                      : Icons.account_balance_wallet_rounded,
                  size: 22.sp,
                  color: color,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        instapay
                            ? 'nursery_pay_type_instapay'.tr
                            : 'nursery_pay_type_wallet'.tr,
                        style:
                            context.typography.xsMedium.copyWith(color: color),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      account.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold.copyWith(color: _ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (account.number.isNotEmpty) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _copy,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'pay_account_number_label'.tr,
                      style: context.typography.xsRegular.copyWith(color: _muted),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        account.number,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.smSemiBold
                            .copyWith(color: _ink),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.copy_rounded, size: 16.sp, color: color),
                  ],
                ),
              ),
            ),
          ],
          if (instapay && account.hasLink) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: _open,
                icon: Icon(Icons.open_in_new_rounded, size: 17.sp),
                label: Text(
                  'pay_invoice_open_pay'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── No accounts ───────────────────────────────────────────────────────────────

class _NoAccounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20.sp, color: _muted),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'pay_invoice_no_accounts'.tr,
              style: context.typography.xsRegular.copyWith(color: _muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proof upload ──────────────────────────────────────────────────────────────

class _ProofBox extends StatelessWidget {
  final File? picked;
  final String? existingUrl;
  final VoidCallback? onTap;

  const _ProofBox({
    required this.picked,
    required this.existingUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _line, width: 1.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: picked != null
            ? Image.file(picked!, fit: BoxFit.cover)
            : (existingUrl != null
                ? AppNetworkImage(url: existingUrl!, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 40.sp, color: _purple),
                      SizedBox(height: 8.h),
                      Text(
                        'pay_invoice_upload_proof'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: _muted),
                      ),
                    ],
                  )),
      ),
    );
  }
}
