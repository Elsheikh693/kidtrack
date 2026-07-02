import '../../../../index/index_main.dart';

class ParentInvoicesView extends StatefulWidget {
  const ParentInvoicesView({super.key});

  @override
  State<ParentInvoicesView> createState() => _ParentInvoicesViewState();
}

class _ParentInvoicesViewState extends State<ParentInvoicesView> {
  late final ParentInvoicesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentInvoicesController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'parent_invoices_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _RemindersSection(controller: controller)),
                SliverToBoxAdapter(child: _SummaryBar(controller: controller)),
                SliverToBoxAdapter(child: _FilterBar(controller: controller)),
                controller.items.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  size: 64, color: Color(0xFFCBD5E1)),
                              const SizedBox(height: 16),
                              Text(
                                'parent_invoices_empty'.tr,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _ParentInvoiceCard(item: controller.items[i]),
                            childCount: controller.items.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Payment Reminders Section ─────────────────────────────────────────────────

class _RemindersSection extends StatelessWidget {
  final ParentInvoicesController controller;
  const _RemindersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reminders = controller.pendingReminders;
      if (reminders.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.notifications_active_rounded,
                  size: 17, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Text(
                'payment_reminder_title'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${reminders.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            ...reminders.map((i) => _ReminderCard(invoice: i)),
            const SizedBox(height: 4),
          ],
        ),
      );
    });
  }
}

class _ReminderCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _ReminderCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isOverdue = invoice.status == 'overdue';
    final color = isOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final bgColor =
        isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.notifications_outlined,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.categoryName ??
                      invoice.title ??
                      'parent_invoices_invoice'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'invoice_status_${invoice.status}'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (invoice.dueDate != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _fmtDate(invoice.dueDate!),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          Text(
            '${invoice.totalAmount.toStringAsFixed(0)} ${'currency'.tr}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ]),
      ),
    );
  }

  String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final ParentInvoicesController controller;
  const _SummaryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            _StatCell(
              label: 'parent_invoices_total_due'.tr,
              value: controller.totalDue.value.toStringAsFixed(0),
              color: const Color(0xFFD97706),
            ),
            _divider(),
            _StatCell(
              label: 'parent_invoices_total_paid'.tr,
              value: controller.totalPaid.value.toStringAsFixed(0),
              color: const Color(0xFF16A34A),
            ),
            _divider(),
            _StatCell(
              label: 'parent_invoices_overdue'.tr,
              value: controller.overdueCount.value.toString(),
              color: const Color(0xFFDC2626),
            ),
          ]),
        ));
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: const Color(0xFFE2E8F0),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ]),
      );
}

class _FilterBar extends StatelessWidget {
  final ParentInvoicesController controller;
  const _FilterBar({required this.controller});

  static const _filters = ['pending', 'paid', 'overdue', 'cancelled'];
  static const _colors = {
    'pending': Color(0xFFD97706),
    'paid': Color(0xFF16A34A),
    'overdue': Color(0xFFDC2626),
    'cancelled': Color(0xFF94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            _Chip(
              label: 'invoice_filter_all'.tr,
              active: controller.selectedStatus.value.isEmpty,
              color: AppColors.primary,
              onTap: () => controller.setStatus(''),
            ),
            ..._filters.map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Chip(
                    label: 'invoice_status_$f'.tr,
                    active: controller.selectedStatus.value == f,
                    color: _colors[f] ?? AppColors.primary,
                    onTap: () => controller.setStatus(f),
                  ),
                )),
          ]),
        ));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? color : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      );
}

class _ParentInvoiceCard extends StatelessWidget {
  final InvoiceModel item;
  const _ParentInvoiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    final isPaid = item.status == 'paid';
    final isOverdue = item.status == 'overdue';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue ? Border.all(color: const Color(0xFFDC2626).withOpacity(0.4)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.categoryName != null)
                      Row(children: [
                        const Icon(Icons.wallet_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          item.categoryName!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ]),
                    if (item.title != null)
                      Text(
                        item.title!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      )
                    else
                      Text(
                        item.categoryName ?? 'parent_invoices_invoice'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'invoice_status_${item.status}'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 12),

            // ── Amount row ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'invoice_total'.tr,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        '${item.totalAmount.toStringAsFixed(0)} ${'currency'.tr}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.discount > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'invoice_discount'.tr,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        '-${item.discount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
              ]),
            ),

            // ── Dates ───────────────────────────────────────────────────────
            if (item.dueDate != null || item.paidAt != null) ...[
              const SizedBox(height: 10),
              Row(children: [
                if (item.dueDate != null) ...[
                  Icon(
                    Icons.schedule_outlined,
                    size: 13,
                    color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${'invoice_due_date'.tr}: ${_fmtDate(item.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
                if (isPaid && item.paidAt != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle, size: 13, color: Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  Text(
                    '${'parent_invoices_paid_on'.tr} ${_fmtDate(item.paidAt!)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A)),
                  ),
                ],
              ]),
            ],

            // ── Overdue banner ───────────────────────────────────────────────
            if (isOverdue) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Text(
                    'parent_invoices_overdue_msg'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return const Color(0xFF16A34A);
      case 'overdue':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFFD97706);
    }
  }
}
