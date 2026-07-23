import '../../../../index/index_main.dart';

class ChaperoneHistoryView extends StatefulWidget {
  const ChaperoneHistoryView({super.key});

  @override
  State<ChaperoneHistoryView> createState() => _ChaperoneHistoryViewState();
}

class _ChaperoneHistoryViewState extends State<ChaperoneHistoryView> {
  late final ChaperoneHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChaperoneHistoryController());
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: controller.selectedDate.value,
      minimumDate: DateTime(2024),
      maximumDate: DateTime.now(),
    );
    if (picked != null) controller.pickDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'tracking_history_title'.tr),
        body: Column(
          children: [
            // ── date filter ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.borderNeutralPrimary
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18.sp, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Obx(() => Text(
                            _fmtDate(controller.selectedDate.value),
                            style: context.typography.smSemiBold
                                .copyWith(color: AppColors.textDefault),
                          )),
                      const Spacer(),
                      Text(
                        'tracking_history_change_date'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.sessions.isEmpty) {
                  return _EmptyState();
                }
                return ListView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  children: controller.sessions
                      .map((s) => _SessionCard(session: s))
                      .toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus_outlined,
              size: 48.sp, color: AppColors.grayMedium),
          SizedBox(height: 12.h),
          Text(
            'tracking_history_empty'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final BusSession session;

  static String _fmtTime(int? ms) {
    if (ms == null) return '--:--';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'billing11_time_pm'.tr : 'billing11_time_am'.tr;
    return '$h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    final isToHome = session.direction == BusTripDirection.toHome;
    final color =
        isToHome ? const Color(0xFF2563EB) : const Color(0xFFD97706);
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Icon(isToHome ? Icons.home_rounded : Icons.school_rounded,
                    size: 18.sp, color: color),
                SizedBox(width: 8.w),
                Text(
                  session.direction.label,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_fmtTime(session.createdAt)} - ${_fmtTime(session.endedAt)}',
                  style: context.typography.smSemiBold.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
          // children rows
          ...session.children.map((c) => _ChildRow(child: c)),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({required this.child});
  final BusChildEntry child;

  @override
  Widget build(BuildContext context) {
    final delivered = child.status == ChildBusStatus.delivered;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(
            delivered ? Icons.check_circle_rounded : Icons.remove_circle_outline,
            size: 16.sp,
            color: delivered
                ? const Color(0xFF059669)
                : AppColors.grayMedium,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              child.childName,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          Text(
            child.status.label,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 11.5,
              color: delivered
                  ? const Color(0xFF059669)
                  : AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
