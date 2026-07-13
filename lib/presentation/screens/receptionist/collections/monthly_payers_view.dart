import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _green = Color(0xFF16A34A);
const _overdue = Color(0xFFDC2626);
const _due = Color(0xFFD97706);
const _bg = Color(0xFFF6F7FB);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);

/// Which bucket behind the finance-tab summary this list renders.
enum MonthlyPayersMode { paid, all }

/// Read-only drill-down for the "collected" and "all" summary cards on the
/// receptionist finance tab. Shows who paid (and who still owes, in [all] mode)
/// for the controller's selected month. Collecting/reminding stays on
/// [LatePayersView]; this screen is a roster, not an action list.
class MonthlyPayersView extends StatelessWidget {
  final CollectionsController controller;
  final MonthlyPayersMode mode;

  const MonthlyPayersView({
    super.key,
    required this.controller,
    required this.mode,
  });

  bool get _paidOnly => mode == MonthlyPayersMode.paid;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: HomeAppBar(
          title: (_paidOnly ? 'collections_paid_title' : 'collections_all_title')
              .tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          final rows = _rows();
          if (rows.isEmpty) {
            return _EmptyState(paidOnly: _paidOnly);
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            itemCount: rows.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => _PayerRow(row: rows[i]),
          );
        }),
      ),
    );
  }

  /// Paid rows (newest first), then — in [all] mode — the still-due rows.
  List<_Row> _rows() {
    final rows = <_Row>[
      for (final p in controller.paidPayers)
        _Row(
          name: p.childName,
          parentName: p.parentName,
          amount: p.amount,
          status: _Status.paid,
        ),
    ];
    if (!_paidOnly) {
      for (final l in controller.latePayers) {
        rows.add(_Row(
          name: l.childName,
          parentName: l.parentName,
          amount: l.amount,
          status: l.isPartial
              ? _Status.partial
              : l.isOverdue
                  ? _Status.overdue
                  : _Status.due,
        ));
      }
    }
    return rows;
  }
}

enum _Status { paid, partial, due, overdue }

class _Row {
  final String name;
  final String parentName;
  final double amount;
  final _Status status;
  const _Row({
    required this.name,
    required this.parentName,
    required this.amount,
    required this.status,
  });
}

class _PayerRow extends StatelessWidget {
  final _Row row;
  const _PayerRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final amount = '${row.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}';
    final paid = row.status == _Status.paid;
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold.copyWith(
                    color: _ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(status: row.status),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  row.parentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular.copyWith(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                amount,
                style: context.typography.smSemiBold.copyWith(
                  color: paid ? _green : _accent,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _Status status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, key) = switch (status) {
      _Status.paid => (_green, 'collections_paid_badge'),
      _Status.partial => (_due, 'collections_partial_badge'),
      _Status.overdue => (_overdue, 'collections_overdue_badge'),
      _Status.due => (_due, 'collections_due_badge'),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        key.tr,
        style: context.typography.xsMedium.copyWith(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool paidOnly;
  const _EmptyState({required this.paidOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76.w,
            height: 76.h,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 38.sp, color: _accent),
          ),
          SizedBox(height: 16.h),
          Text(
            (paidOnly ? 'collections_paid_empty' : 'collections_no_dues').tr,
            style: context.typography.smSemiBold.copyWith(
              color: _muted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
