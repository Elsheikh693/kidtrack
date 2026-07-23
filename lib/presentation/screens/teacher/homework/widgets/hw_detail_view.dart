import '../../../../../index/index_main.dart';

const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF16A34A);
const _kAmber = Color(0xFFD97706);
const _kRed = Color(0xFFDC2626);
const _kGray = Color(0xFF6B7280);

class HwDetailView extends StatefulWidget {
  const HwDetailView({
    super.key,
    required this.homework,
    required this.children,
    required this.initialStatuses,
    this.submissions = const {},
  });

  final HomeworkModel homework;
  final List<ChildModel> children;
  final Map<String, HomeworkStatus> initialStatuses;
  // childId → the parent's at-home submission (incl. "how did it go" answers).
  final Map<String, HomeworkSubmissionModel> submissions;

  @override
  State<HwDetailView> createState() => _HwDetailViewState();
}

class _HwDetailViewState extends State<HwDetailView>
    with SingleTickerProviderStateMixin {
  late final Map<String, HomeworkStatus> _statuses;
  late final AnimationController _ctrl;
  bool _saving = false;
  // Child-list filter by solve status: all / completed / partial / not / absent
  // / unmarked. Lets the teacher see e.g. only "who didn't do it".
  String _filter = 'all';

  List<ChildModel> get _filteredChildren {
    if (_filter == 'all') return widget.children;
    return widget.children.where((c) {
      final s = _statuses[c.key ?? ''];
      return switch (_filter) {
        'completed' => s == HomeworkStatus.completed,
        'partial' => s == HomeworkStatus.partiallyCompleted,
        'not' => s == HomeworkStatus.notCompleted,
        'absent' => s == HomeworkStatus.absent,
        'unmarked' => s == null,
        _ => true,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _statuses = Map.from(widget.initialStatuses);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setStatus(String childId, HomeworkStatus s) {
    setState(() => _statuses[childId] = s);
  }

  void _bulkSet(HomeworkStatus s) {
    setState(() {
      for (final c in widget.children) {
        _statuses[c.key ?? ''] = s;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final ctrl = Get.find<HomeworkTabController>();
      await ctrl.saveStatuses(
          homework: widget.homework, statuses: _statuses);
      Get.back();
      Get.snackbar(
        'teacherhom36_done'.tr,
        'teacherhom36_follow_up_saved'.tr,
        backgroundColor: _kGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int get _completedCount =>
      _statuses.values.where((s) => s == HomeworkStatus.completed).length;
  int get _partialCount =>
      _statuses.values.where((s) => s == HomeworkStatus.partiallyCompleted).length;
  int get _notCompletedCount =>
      _statuses.values.where((s) => s == HomeworkStatus.notCompleted).length;
  int get _absentCount =>
      _statuses.values.where((s) => s == HomeworkStatus.absent).length;
  int get _unmarkedCount => widget.children.length - _statuses.length;

  double get _rate {
    final total = widget.children.length;
    if (total == 0) return 0;
    return (_completedCount + _partialCount * 0.5) / total;
  }

  @override
  Widget build(BuildContext context) {
    final hw = widget.homework;
    final isDueDateSet = hw.dueDate != null;
    final isOverdue =
        isDueDateSet && hw.dueDate! < DateTime.now().millisecondsSinceEpoch;

    final bodyAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    );

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _GradientHeader(hw: hw, isOverdue: isOverdue),
            Expanded(
              child: FadeTransition(
                opacity: bodyAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(bodyAnim),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
                    children: [
                      _SummaryCard(
                        total: widget.children.length,
                        completed: _completedCount,
                        partial: _partialCount,
                        notCompleted: _notCompletedCount,
                        absent: _absentCount,
                        unmarked: _unmarkedCount,
                        rate: _rate,
                      ),
                      SizedBox(height: 12.h),
                      _BulkBar(onBulk: _bulkSet),
                      SizedBox(height: 16.h),
                      // Section label
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: _kBlue.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.people_rounded,
                                size: 14.sp, color: _kBlue),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'hw_detail_performance'.tr,
                            style: context.typography.displaySmBold.copyWith(
                              fontSize: 15,
                              color: _kBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _FilterBar(
                        selected: _filter,
                        counts: {
                          'all': widget.children.length,
                          'completed': _completedCount,
                          'partial': _partialCount,
                          'not': _notCompletedCount,
                          'absent': _absentCount,
                          'unmarked': _unmarkedCount,
                        },
                        onSelect: (f) => setState(() => _filter = f),
                      ),
                      SizedBox(height: 10.h),
                      if (_filteredChildren.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Text(
                              'hw_filter_empty'.tr,
                              style: context.typography.smMedium.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        )
                      else
                        ..._filteredChildren.map((child) {
                          final childId = child.key ?? '';
                          final status = _statuses[childId];
                          return _ChildRow(
                            name: child.fullName,
                            status: status,
                            onTap: _setStatus,
                            childId: childId,
                            submission: widget.submissions[childId],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _SaveFab(saving: _saving, onSave: _save),
      ),
    );
  }
}

// ── Gradient header ────────────────────────────────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.hw, required this.isOverdue});
  final HomeworkModel hw;
  final bool isOverdue;

  static String _dateLabel(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return localizeDigits('${d.day} ${monthName(d.month)}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), _kBlue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30.h,
            left: -30.w,
            child: Container(
              width: 130.w,
              height: 130.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20.h,
            right: 20.w,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back row
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 4.h, 16.w, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 20.sp),
                        onPressed: Get.back,
                      ),
                      Expanded(
                        child: Text(
                          hw.title,
                          style: context.typography.mdBold.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chips
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      if (hw.subjectName != null &&
                          hw.subjectName!.isNotEmpty)
                        _HeaderChip(
                          label: hw.subjectName!,
                          icon: Icons.book_rounded,
                        ),
                      _HeaderChip(
                        label: _dateLabel(hw.createdAt),
                        icon: Icons.calendar_today_rounded,
                      ),
                      if (hw.dueDate != null)
                        _HeaderChip(
                          label: '${'hw_due_date'.tr}: ${_dateLabel(hw.dueDate)}',
                          icon: isOverdue
                              ? Icons.warning_rounded
                              : Icons.schedule_rounded,
                          danger: isOverdue,
                        ),
                    ],
                  ),
                ),
                // Description
                if (hw.description != null && hw.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: Text(
                      hw.description!,
                      style: context.typography.xsRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.icon,
    this.danger = false,
  });
  final String label;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: danger
              ? const Color(0xFFDC2626).withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: danger
                ? const Color(0xFFDC2626).withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 5.w),
            Text(
              label,
              style: context.typography.smSemiBold.copyWith(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

// ── Summary card ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.completed,
    required this.partial,
    required this.notCompleted,
    required this.absent,
    required this.unmarked,
    required this.rate,
  });
  final int total, completed, partial, notCompleted, absent, unmarked;
  final double rate;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _kBlue.withValues(alpha: 0.08),
              blurRadius: 14.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'hw_detail_summary'.tr,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$total ${'hw_students_count'.tr}',
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 12,
                      color: _kBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // Animated progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: rate),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutQuart,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8.h,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(_kGreen),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '${(value * 100).round()}% ${'teacherhom36_completion'.tr}',
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 11,
                      color: _kGreen,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            // Stat pills row
            Row(
              children: [
                _AnimatedStatPill(
                    value: completed, label: 'teacherhom36_status_completed'.tr, color: _kGreen),
                _AnimatedStatPill(
                    value: partial, label: 'teacherhom36_status_partial'.tr, color: _kAmber),
                _AnimatedStatPill(
                    value: notCompleted, label: 'teacherhom36_status_not_completed'.tr, color: _kRed),
                _AnimatedStatPill(
                    value: absent, label: 'teacherhom36_status_absent'.tr, color: _kGray),
                _AnimatedStatPill(
                  value: unmarked,
                  label: 'teacherhom36_status_none'.tr,
                  color: const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ],
        ),
      );
}

class _AnimatedStatPill extends StatelessWidget {
  const _AnimatedStatPill(
      {required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
          builder: (context, v, _) => Column(
            children: [
              Text(
                '${v.round()}',
                style: context.typography.lgBold.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(
                  fontSize: 9,
                  color: const Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ── Bulk bar ───────────────────────────────────────────────────────────────────

class _BulkBar extends StatelessWidget {
  const _BulkBar({required this.onBulk});
  final void Function(HomeworkStatus) onBulk;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'teacherhom36_bulk_all'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(width: 8.w),
            _BulkBtn(
              label: 'teacherhom36_status_completed'.tr,
              color: _kGreen,
              icon: Icons.check_circle_rounded,
              onTap: () => onBulk(HomeworkStatus.completed),
            ),
            SizedBox(width: 6.w),
            _BulkBtn(
              label: 'teacherhom36_status_partial'.tr,
              color: _kAmber,
              icon: Icons.remove_circle_rounded,
              onTap: () => onBulk(HomeworkStatus.partiallyCompleted),
            ),
            SizedBox(width: 6.w),
            _BulkBtn(
              label: 'teacherhom36_status_not_completed'.tr,
              color: _kRed,
              icon: Icons.cancel_rounded,
              onTap: () => onBulk(HomeworkStatus.notCompleted),
            ),
            SizedBox(width: 6.w),
            _BulkBtn(
              label: 'teacherhom36_status_absent'.tr,
              color: _kGray,
              icon: Icons.person_off_rounded,
              onTap: () => onBulk(HomeworkStatus.absent),
            ),
          ],
        ),
      );
}

class _BulkBtn extends StatelessWidget {
  const _BulkBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14.sp, color: color),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 9,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Child row ──────────────────────────────────────────────────────────────────

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.name,
    required this.status,
    required this.onTap,
    required this.childId,
    this.submission,
  });
  final String name;
  final HomeworkStatus? status;
  final void Function(String, HomeworkStatus) onTap;
  final String childId;
  final HomeworkSubmissionModel? submission;

  // Parent "how did it go" answers rendered as compact chips. Green = good
  // outcome (didn't need help / hand not guided / did it easily), amber = the
  // opposite. Empty when the parent hasn't confirmed or answered.
  List<Widget> _answerChips() {
    final sub = submission;
    if (sub == null) return const [];
    final chips = <Widget>[
      _AnswerChip(text: 'hw_done_at_home'.tr, good: true, icon: Icons.home_rounded),
    ];
    if (sub.neededHelp != null) {
      chips.add(_AnswerChip(
        text: '${'hw_q_needed_help_short'.tr}: '
            '${sub.neededHelp! ? 'hw_answer_yes'.tr : 'hw_answer_no'.tr}',
        good: sub.neededHelp == false,
      ));
    }
    if (sub.guidedHand != null) {
      chips.add(_AnswerChip(
        text: '${'hw_q_guided_hand_short'.tr}: '
            '${sub.guidedHand! ? 'hw_answer_yes'.tr : 'hw_answer_no'.tr}',
        good: sub.guidedHand == false,
      ));
    }
    if (sub.didEasily != null) {
      chips.add(_AnswerChip(
        text: '${'hw_q_did_easily_short'.tr}: '
            '${sub.didEasily! ? 'hw_answer_yes'.tr : 'hw_answer_no'.tr}',
        good: sub.didEasily == true,
      ));
    }
    return chips;
  }

  static const _statuses = [
    HomeworkStatus.completed,
    HomeworkStatus.partiallyCompleted,
    HomeworkStatus.notCompleted,
    HomeworkStatus.absent,
  ];

  Color get _avatarColor {
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF8B5CF6),
      const Color(0xFF16A34A), const Color(0xFFD97706),
      const Color(0xFFDC2626), const Color(0xFFEC4899),
    ];
    return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  Color get _statusColor {
    return switch (status) {
      HomeworkStatus.completed => _kGreen,
      HomeworkStatus.partiallyCompleted => _kAmber,
      HomeworkStatus.notCompleted => _kRed,
      HomeworkStatus.absent => _kGray,
      _ => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = status != null ? _statusColor : const Color(0xFFE2E8F0);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4.w,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: _avatarColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _avatarColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty ? name[0] : '؟',
                          style: context.typography.displaySmBold.copyWith(
                            fontSize: 14,
                            color: _avatarColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: context.typography.smSemiBold.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            if (submission != null) ...[
                              SizedBox(height: 5.h),
                              Wrap(
                                spacing: 4.w,
                                runSpacing: 4.h,
                                children: _answerChips(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Row(
                        children: _statuses
                            .map(
                              (s) => Padding(
                                padding: EdgeInsets.only(right: 5.w),
                                child: _StatusBtn(
                                  status: s,
                                  isActive: status == s,
                                  onTap: () => onTap(childId, s),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  const _StatusBtn({
    required this.status,
    required this.isActive,
    required this.onTap,
  });
  final HomeworkStatus status;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 33.w,
        height: 33.h,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.07),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.2),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Icon(
          status.icon,
          color: isActive ? Colors.white : color.withValues(alpha: 0.55),
          size: 16.sp,
        ),
      ),
    );
  }
}

// ── Child-list filter bar ───────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final String selected;
  final Map<String, int> counts;
  final void Function(String) onSelect;

  static List<(String, String, Color)> get _options => <(String, String, Color)>[
    ('all', 'teacherhom36_status_all'.tr, _kBlue),
    ('completed', 'teacherhom36_status_completed'.tr, _kGreen),
    ('partial', 'teacherhom36_status_partial'.tr, _kAmber),
    ('not', 'teacherhom36_status_not_completed'.tr, _kRed),
    ('absent', 'teacherhom36_status_absent'.tr, _kGray),
    ('unmarked', 'teacherhom36_status_none'.tr, const Color(0xFF94A3B8)),
  ];

  @override
  Widget build(BuildContext context) {
    // Always offer "all"; only offer a status once at least one child has it.
    final visible = _options
        .where((o) => o.$1 == 'all' || (counts[o.$1] ?? 0) > 0)
        .toList();
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: visible.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final o = visible[i];
          return _FilterChip(
            label: o.$2,
            count: counts[o.$1] ?? 0,
            color: o.$3,
            isActive: selected == o.$1,
            onTap: () => onSelect(o.$1),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isActive ? color : color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 12,
                  color: isActive ? Colors.white : color,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                '$count',
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? Colors.white
                      : color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Parent answer chip ──────────────────────────────────────────────────────────

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({required this.text, required this.good, this.icon});
  final String text;
  final bool good;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = good ? _kGreen : _kAmber;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10.sp, color: color),
            SizedBox(width: 3.w),
          ],
          Text(
            text,
            style: context.typography.xsMedium.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Save FAB ───────────────────────────────────────────────────────────────────

class _SaveFab extends StatelessWidget {
  const _SaveFab({required this.saving, required this.onSave});
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
              shadowColor: _kBlue.withValues(alpha: 0.3),
            ),
            onPressed: saving ? null : onSave,
            icon: saving
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Icon(Icons.save_rounded, size: 20.sp),
            label: Text(
              'hw_save'.tr,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
}
