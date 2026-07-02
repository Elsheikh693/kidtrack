import '../../../../index/index_main.dart';
import '../../../../Data/models/child_daily_event/child_daily_event_model.dart';

class ParentTodayScheduleView extends StatefulWidget {
  const ParentTodayScheduleView({super.key});

  @override
  State<ParentTodayScheduleView> createState() =>
      _ParentTodayScheduleViewState();
}

class _ParentTodayScheduleViewState extends State<ParentTodayScheduleView>
    with SingleTickerProviderStateMixin {
  late final ParentDashboardController _ctrl;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = initController(() => ParentDashboardController());
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  static ({IconData icon, Color color}) _styleForEvent(String eventType) {
    switch (eventType) {
      case ChildEventType.checkIn:
        return (icon: Icons.login_rounded, color: const Color(0xFF059669));
      case ChildEventType.checkOut:
        return (icon: Icons.logout_rounded, color: const Color(0xFF64748B));
      case ChildEventType.mealStarted:
        return (icon: Icons.restaurant_rounded, color: const Color(0xFFDC2626));
      case ChildEventType.mealCompleted:
        return (icon: Icons.restaurant_menu_rounded, color: const Color(0xFF059669));
      case ChildEventType.napStarted:
        return (icon: Icons.bedtime_rounded, color: const Color(0xFF7C3AED));
      case ChildEventType.napCompleted:
        return (icon: Icons.wb_sunny_rounded, color: const Color(0xFFF59E0B));
      case ChildEventType.busBoarded:
        return (icon: Icons.directions_bus_rounded, color: const Color(0xFFD97706));
      case ChildEventType.busArrived:
        return (icon: Icons.directions_bus_rounded, color: const Color(0xFF059669));
      case ChildEventType.activityStarted:
        return (icon: Icons.auto_stories_rounded, color: AppColors.primary);
      case ChildEventType.activityCompleted:
        return (icon: Icons.stars_rounded, color: AppColors.primary);
      case ChildEventType.pickupRequested:
        return (icon: Icons.directions_car_rounded, color: const Color(0xFFF97316));
      case ChildEventType.noteAdded:
        return (icon: Icons.sticky_note_2_rounded, color: const Color(0xFF2563EB));
      case ChildEventType.medicineGiven:
        return (icon: Icons.medical_services_rounded, color: const Color(0xFFDC2626));
      case ChildEventType.bathroom:
        return (icon: Icons.wc_rounded, color: const Color(0xFF0891B2));
      default:
        return (icon: Icons.circle_rounded, color: AppColors.textSecondaryParagraph);
    }
  }

  static String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _fade(int index, Widget child) {
    final anim = CurvedAnimation(
      parent: _animCtrl,
      curve: Interval(
        (index * 0.08).clamp(0.0, 0.6),
        ((index * 0.08) + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (_, w) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
          child: w,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios,
                color: Colors.white, size: 20),
          ),
          title: Text(
            'parent_today_schedule_title'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Obx(() {
          final events = _ctrl.todayTimeline2;

          if (events.isEmpty) {
            return _EmptyState();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _fade(0, _ScheduleHeader()),
                ...List.generate(events.length, (i) {
                  final e = events[i];
                  final isLast = i == events.length - 1;
                  final style = _styleForEvent(e.eventType);
                  return _fade(
                    i + 1,
                    _VerticalEventTile(
                      time: _formatTime(e.createdAt),
                      title: e.title ?? e.eventType,
                      subtitle: e.description,
                      icon: style.icon,
                      color: style.color,
                      isCurrent: isLast,
                      isDone: !isLast,
                      isLast: isLast,
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'parent_timeline_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 72,
            color: AppColors.grayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أحداث مسجلة اليوم بعد',
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          const SizedBox(height: 6),
          Text(
            'ستظهر هنا أحداث يومك عند تسجيل الحضور',
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

// ── Vertical Event Tile ───────────────────────────────────────────────────────

class _VerticalEventTile extends StatelessWidget {
  const _VerticalEventTile({
    required this.time,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.isCurrent,
    required this.isDone,
    required this.isLast,
  });

  final String time;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isCurrent;
  final bool isDone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Time column ────────────────────────────────────────────────
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, top: 14),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? color
                      : AppColors.textSecondaryParagraph,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // ── Timeline spine ────────────────────────────────────────────
          Column(
            children: [
              if (isCurrent)
                _PulsingDot(color: color)
              else
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.grayMedium : Colors.white,
                    border: Border.all(
                      color: isDone ? AppColors.grayMedium : AppColors.borderNeutralPrimary,
                      width: isDone ? 0 : 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 9)
                      : null,
                ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.borderNeutralPrimary,
                  ),
                ),
            ],
          ),
          // ── Event card ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color.withValues(alpha: 0.08)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrent
                      ? Border.all(
                          color: color.withValues(alpha: 0.35),
                          width: 1.5)
                      : Border.all(
                          color: AppColors.borderNeutralPrimary
                              .withValues(alpha: 0.5)),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.backgroundNeutral100
                            : color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : icon,
                        color: isDone ? AppColors.grayMedium : color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isDone
                                  ? AppColors.textSecondaryParagraph
                                  : AppColors.textDefault,
                            ),
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryParagraph,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          _StatusBadge(
                            isDone: isDone,
                            isCurrent: isCurrent,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isDone,
    required this.isCurrent,
    required this.color,
  });
  final bool isDone;
  final bool isCurrent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return _Badge(
        label: 'parent_schedule_status_done'.tr,
        color: AppColors.grayMedium,
        bgColor: AppColors.backgroundNeutral100,
      );
    } else if (isCurrent) {
      return _Badge(
        label: 'parent_schedule_status_current'.tr,
        color: color,
        bgColor: color.withValues(alpha: 0.12),
        dot: true,
      );
    } else {
      return _Badge(
        label: 'parent_schedule_status_upcoming'.tr,
        color: AppColors.textSecondaryParagraph,
        bgColor: AppColors.backgroundNeutral100,
      );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.bgColor,
    this.dot = false,
  });
  final String label;
  final Color color;
  final Color bgColor;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing Dot (for current event) ──────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _pulse = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context2, child2) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color
                      .withValues(alpha: (1 - _ctrl.value) * 0.35),
                ),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
