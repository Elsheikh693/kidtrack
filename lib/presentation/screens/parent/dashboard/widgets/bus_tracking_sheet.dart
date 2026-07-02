import 'dart:async';
import '../../../../../index/index_main.dart';
import 'live_map_widget.dart';

void showBusTrackingSheet(BuildContext context, String branchId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BusTrackingSheet(branchId: branchId),
  );
}

class _BusTrackingSheet extends StatefulWidget {
  const _BusTrackingSheet({required this.branchId});
  final String branchId;

  @override
  State<_BusTrackingSheet> createState() => _BusTrackingSheetState();
}

class _BusTrackingSheetState extends State<_BusTrackingSheet> {
  final _service = BusTrackingService();
  StreamSubscription<BusSession?>? _sub;
  BusSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sub = _service.watchActiveSessions(widget.branchId).listen((s) {
      if (mounted) setState(() { _session = s; _loading = false; });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            _SheetHandle(),
            _SheetHeader(session: _session),
            if (_loading)
              Padding(
                padding: EdgeInsets.all(40.w),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_session == null)
              _NoActiveSession()
            else ...[
              LiveMapWidget(session: _session!),
              _SessionInfo(session: _session!),
              _ChildrenStatusList(session: _session!),
            ],
          ],
        )),
    );
  }
}

// ── Handle ────────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.borderNeutralPrimary,
          borderRadius: BorderRadius.circular(2.r),
        )),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.session});
  final BusSession? session;

  @override
  Widget build(BuildContext context) {
    final active = session?.isActive ?? false;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.directions_bus_rounded,
                color: Color(0xFFD97706), size: 22.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'tracking_sheet_title'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                if (active)
                  Row(
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        )),
                      SizedBox(width: 5.w),
                      Text(
                        'tracking_live_label'.tr,
                        style: context.typography.smSemiBold.copyWith(color: const Color(0xFF059669), fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── No active session ─────────────────────────────────────────────────────────

class _NoActiveSession extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 32.w),
      child: Column(
        children: [
          Icon(Icons.bus_alert_rounded,
              size: 56.sp, color: AppColors.textSecondaryParagraph),
          SizedBox(height: 12.h),
          Text(
            'tracking_no_active_session'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

// ── Session info ──────────────────────────────────────────────────────────────

class _SessionInfo extends StatelessWidget {
  const _SessionInfo({required this.session});
  final BusSession session;

  @override
  Widget build(BuildContext context) {
    final loc = session.location;
    final lastUpdate = loc != null
        ? DateTime.fromMillisecondsSinceEpoch(loc.updatedAt)
        : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0.h),
      child: Row(
        children: [
          Icon(Icons.person_rounded,
              size: 16.sp, color: AppColors.textSecondaryParagraph),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              session.chaperoneName,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          if (lastUpdate != null)
            Text(
              '${'tracking_last_update'.tr} ${_formatTime(lastUpdate)}',
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Children status list ──────────────────────────────────────────────────────

class _ChildrenStatusList extends StatelessWidget {
  const _ChildrenStatusList({required this.session});
  final BusSession session;

  @override
  Widget build(BuildContext context) {
    if (session.children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Text(
            'tracking_children_list'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        ...session.children.map((c) => _ChildStatusTile(child: c)),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _ChildStatusTile extends StatelessWidget {
  const _ChildStatusTile({required this.child});
  final BusChildEntry child;

  Color get _color {
    switch (child.status) {
      case ChildBusStatus.pending:   return const Color(0xFFD97706);
      case ChildBusStatus.onBus:     return const Color(0xFF2563EB);
      case ChildBusStatus.delivered: return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            backgroundImage: child.childImage != null
                ? appCachedImageProvider(child.childImage!)
                : null,
            child: child.childImage == null
                ? Icon(Icons.child_care_rounded, color: color, size: 14.sp)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              child.childName,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              child.status.label,
              style: context.typography.smSemiBold.copyWith(color: color, fontSize: 11),
            )),
        ],
      ),
    );
  }
}
