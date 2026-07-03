import 'package:flutter/cupertino.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Data/models/child_daily_event/child_daily_event_model.dart';
import 'widgets/latest_post_card.dart';

// ════════════════════════════════════════════════════════════════════════════
//  Parent Home — adaptive "story of the child's day"
//  Driven by ParentDashboardController (real Firebase data).
//  Day-phase (before / during / after) is derived from the child's status.
// ════════════════════════════════════════════════════════════════════════════

const _kPurple = Color(0xFF6C4DDB);
const _kPurpleDeep = Color(0xFF3F2AA8);
const _kGreen = Color(0xFF16A34A);
const _kBlue = Color(0xFF2563EB);
const _kAmber = Color(0xFFD97706);
const _kRed = Color(0xFFDC2626);
const _kBg = Color(0xFFF4F4F8);
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);

// ── Shared design tokens ─────────────────────────────────────────────────────
// One consistent radius + a soft, diffuse card shadow so every surface on the
// home reads as the same "material" — the small touches that make it premium.
const _kCardRadius = 20.0;

final List<BoxShadow> _kCardShadow = [
  BoxShadow(
    color: const Color(0xFF1E293B).withValues(alpha: 0.06),
    blurRadius: 24.r,
    offset: Offset(0.w, 10.h),
    spreadRadius: -6),
];

/// A coloured "lift" used under gradient hero cards — soft and diffuse, not a
/// neon glow.
List<BoxShadow> _kColoredShadow(Color c) => [
      BoxShadow(
        color: c.withValues(alpha: 0.28),
        blurRadius: 34.r,
        offset: Offset(0.w, 16.h),
        spreadRadius: -10),
    ];

enum _Phase { before, during, after }

class ParentHomeMockup extends StatelessWidget {
  const ParentHomeMockup({super.key, required this.controller});

  final ParentDashboardController controller;

  // Day-phase is derived automatically from the child's live status —
  // no manual tabs. Reception check-in/out flips it.
  static _Phase _phaseFor(EffectiveChildStatus s) {
    if (s.key == ChildStatus.notArrived) return _Phase.before;
    if (s.key == ChildStatus.checkedOut || s.key == ChildStatus.onBus) {
      return _Phase.after;
    }
    return _Phase.during;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: _kBg,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: EdgeInsets.only(top: topInset),
              child: const _HomeShimmer(),
            );
          }
          // History Mode: the whole page becomes a read-only "day recap".
          if (!controller.isToday) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, topInset + 8, 16.w, 24.h),
              children: [
                StaggerItem(index: 0, child: _TopBar(controller: controller)),
                SizedBox(height: 12.h),
                StaggerItem(
                  index: 1,
                  child: _HistoryBanner(controller: controller),
                ),
                SizedBox(height: 14.h),
                StaggerItem(
                  index: 2,
                  child: _HistoryRecapHero(controller: controller),
                ),
                SizedBox(height: 18.h),
                StaggerItem(
                  index: 3,
                  child: _TodayTimelinePreview(
                      controller: controller, history: true),
                ),
                SizedBox(height: 18.h),
                StaggerItem(
                  index: 4,
                  child: _PhotosStrip(controller: controller),
                ),
                SizedBox(height: 18.h),
                StaggerItem(
                  index: 5,
                  child: _HistoryNotesSection(controller: controller),
                ),
              ],
            );
          }
          final phase = _phaseFor(controller.effectiveStatus);
          final isHoliday = controller.isSelectedDayHoliday;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 120.h),
            children: [
              StaggerItem(
                index: 0,
                child: _HeaderHero(
                  controller: controller,
                  phase: phase,
                  topInset: topInset,
                  isHoliday: isHoliday,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0.h),
                child: Column(
                  children: [
                    StaggerItem(
                      index: 2,
                      child: _AttentionStrip(controller: controller),
                    ),
                    SizedBox(height: 18.h),
                    LatestPostCard(controller: controller),
                    _NextEventCard(controller: controller),
                    const StaggerItem(
                      index: 3,
                      child: _ContactNurseryCard(),
                    ),
                    SizedBox(height: 18.h),
                    // On a holiday there is no live day to track — hide the
                    // timeline so the header's "اليوم إجازة" reads clean.
                    if (!isHoliday) ...[
                      StaggerItem(
                        index: 4,
                        child: _TodayTimelinePreview(controller: controller),
                      ),
                      SizedBox(height: 18.h),
                    ],
                    StaggerItem(
                      index: 5,
                      child: _PhotosStrip(controller: controller),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ));
  }
}

// ─── Contact the nursery (chat with the manager) ──────────────────────────────

class _ContactNurseryCard extends StatelessWidget {
  const _ContactNurseryCard();

  static const _chat = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openParentChat,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 15.h, 14.w, 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kCardRadius.r),
          boxShadow: _kCardShadow,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: _chat.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child:
                      Icon(Icons.forum_rounded, color: _chat, size: 23.sp),
                ),
                Positioned(
                  top: -5.h,
                  right: -5.w,
                  child: Obx(() {
                    final n = Get.find<ActiveChildService>().chatUnread.value;
                    if (n <= 0) return const SizedBox.shrink();
                    return ChatUnreadBadge(count: n);
                  }),
                ),
              ],
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'chat_with_nursery'.tr,
                    style: context.typography.mdBold.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'chat_home_card_subtitle'.tr,
                    style: context.typography.xsRegular.copyWith(
                      fontSize: 11.5,
                      color: _kMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: _kMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Lightweight loading shimmer ──────────────────────────────────────────────

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double r = 18}) => Container(
          width: double.infinity,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ));
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0.h),
        children: [
          Row(children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
            SizedBox(width: 12.w),
            Expanded(child: box(40, r: 10)),
          ]),
          SizedBox(height: 18.h),
          box(230, r: 24),
          SizedBox(height: 18.h),
          box(90),
          SizedBox(height: 12.h),
          box(110),
          SizedBox(height: 18.h),
          box(260),
        ],
      ),
    );
  }
}

// ─── Top app bar: child identity + notification / settings ───────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Brand bar: same animated logo + wordmark as the app's main home ──
        Row(
          children: [
            const _AnimatedLogo(),
            SizedBox(width: 10.w),
            const _AnimatedBrand(),
            const Spacer(),
            _TopIcon(
              icon: Icons.chat_rounded,
              iconColor: const Color(0xFF25D366),
              onTap: openNurseryWhatsApp,
            ),
            SizedBox(width: 10.w),
            _TopIcon(
              icon: Icons.notifications_none_rounded,
              badge: true,
              onTap: () => Get.toNamed(notificationsView),
            ),
            SizedBox(width: 10.w),
            _TopIcon(
              icon: Icons.settings_outlined,
              onTap: () => Get.to(() => const ParentAccountView()),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        // ── Identity: child name (right) + the day selector on the
        //    opposite side, centred against the name ──────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Obx(() {
                final name = controller.childName.isNotEmpty
                    ? controller.childName
                    : 'parent_default_name'.tr;
                final hasSiblings = controller.siblings.length > 1;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasSiblings
                      ? () => _showChildSwitcher(context, controller)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.xlBold.copyWith(color: _kInk, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.1),
                        ),
                      ),
                      if (hasSiblings) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: _kPurple.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20.sp,
                            color: _kPurple)),
                      ],
                    ],
                  ),
                );
              }),
            ),
            SizedBox(width: 10.w),
            // Whole chip opens the picker; a horizontal swipe steps day-by-day.
            _HomeDateSubtitle(controller: controller),
          ],
        ),
      ],
    );
  }
}

// ─── Animated KidTrack brand (logo chip + wordmark) ──────────────────────────
// Mirrors the entrance used on the app's main (discovery) home so the parent
// home opens with the same branded, "alive" feel.

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = CurvedAnimation(parent: _entry, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _entry.forward().whenComplete(() {
      if (mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 44.w,
      height: 44.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withValues(alpha: 0.12),
            blurRadius: 10.r,
            offset: Offset(0.w, 4.h)),
        ],
      ),
      child: Image.asset(Images.splash, fit: BoxFit.contain));

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _pulse]),
      builder: (context, child) {
        final breathe = 1 + _pulse.value * 0.06;
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.4 + _scale.value * 0.6) * breathe,
            child: child,
          ),
        );
      },
      child: box,
    );
  }
}

class _AnimatedBrand extends StatefulWidget {
  const _AnimatedBrand();

  @override
  State<_AnimatedBrand> createState() => _AnimatedBrandState();
}

class _AnimatedBrandState extends State<_AnimatedBrand>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _slide;
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = CurvedAnimation(parent: _entry, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _slide = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _entry.forward().whenComplete(() {
      if (mounted) _shimmer.repeat();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Text(
      'app_brand_name'.tr,
      style: context.typography.xlBold.copyWith(color: _kPurple, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4, shadows: [
          Shadow(color: _kPurple.withValues(alpha: 0.30), blurRadius: 14),
        ]),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _shimmer]),
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            // Slide in from the right (RTL) as it pops.
            offset: Offset((1 - _slide.value) * 26, 0.h),
            child: Transform.scale(
              scale: 0.4 + _scale.value * 0.6,
              alignment: Alignment.centerRight,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: _sheenShader,
                child: child,
              ),
            ),
          ),
        );
      },
      child: brand,
    );
  }

  /// Moving-highlight sweep that travels across the wordmark then rests.
  Shader _sheenShader(Rect bounds) {
    final raw = (_shimmer.value / 0.4).clamp(0.0, 1.0);
    final p = -0.25 + raw * 1.5;
    final s1 = (p - 0.18).clamp(0.0, 1.0);
    final s2 = p.clamp(0.0, 1.0);
    final s3 = (p + 0.18).clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_kPurple, _kPurple, Colors.white, _kPurple, _kPurple],
      stops: [0.0, s1, s2, s3, 1.0],
    ).createShader(bounds);
  }
}

// ─── Child switcher (siblings) ─────────────────────────────────────────────────

void _showChildSwitcher(
  BuildContext context,
  ParentDashboardController controller,
) {
  Get.bottomSheet(
    Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                )),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Icon(Icons.switch_account_rounded,
                        size: 20.sp, color: _kPurple),
                    SizedBox(width: 8.w),
                    Text(
                      'parent_switch_child'.tr,
                      style: context.typography.mdBold.copyWith(color: _kInk, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                final siblings = controller.siblings;
                final activeId = controller.activeChildId;
                return Column(
                  children: [
                    for (final child in siblings)
                      _ChildSwitchTile(
                        child: child,
                        isActive: child.id == activeId,
                        onTap: () {
                          Get.back();
                          controller.switchChild(child.id);
                        },
                      ),
                  ],
                );
              }),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _ChildSwitchTile extends StatelessWidget {
  const _ChildSwitchTile({
    required this.child,
    required this.isActive,
    required this.onTap,
  });

  final ActiveChildOption child;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = child.gender == 'female' ? _kRed : _kPurple;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: (child.image != null && child.image!.isNotEmpty)
                  ? Image(image: appCachedImageProvider(child.image!), fit: BoxFit.cover,
                      width: 44, height: 44,
                      errorBuilder: (_, _, _) => _initial(child.name))
                  : _initial(child.name),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                child.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.displaySmBold.copyWith(color: isActive ? color : _kInk, fontSize: 15),
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle_rounded, size: 22.sp, color: color)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  size: 22.sp, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _initial(String name) => Text(
        name.isNotEmpty ? name.characters.first : '؟',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      );
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({
    required this.icon,
    this.badge = false,
    this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final bool badge;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 21.sp, color: iconColor ?? _kInk),
          if (badge)
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: _kRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                )),
            ),
        ],
      ),
      ),
    );
  }
}

// ─── Date subtitle (اليوم ▾ / أمس ▾ / السبت ٢٧ يونيو ▾) ───────────────────────
// Reads as a quiet subtitle under the child's name. The whole line is tappable
// (opens the picker); a horizontal swipe steps one day without opening it.

class _HomeDateSubtitle extends StatelessWidget {
  const _HomeDateSubtitle({required this.controller, this.onDark = false});
  final ParentDashboardController controller;

  /// Renders white-on-glass for use inside the coloured header.
  final bool onDark;

  /// Step the selected day. [delta] is in days (+1 = forward, -1 = back).
  /// Future days are clamped to today since there's nothing to show yet.
  void _step(int delta) {
    final next = controller.selectedDate.value.add(Duration(days: delta));
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month, now.day))) return;
    controller.setDate(next);
  }

  void _openPicker(BuildContext context) {
    final now = DateTime.now();
    DateTime temp = controller.selectedDate.value;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 320.h,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('إلغاء',
                          style: context.typography.smRegular.copyWith(color: _kMuted, fontSize: 14)),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.backToToday();
                      },
                      child: Text('اليوم',
                          style: context.typography.displaySmBold.copyWith(color: _kPurple, fontSize: 14)),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.setDate(temp);
                      },
                      child: Text('تم',
                          style: context.typography.displaySmBold.copyWith(color: _kPurple, fontSize: 14, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: controller.selectedDate.value,
                  maximumDate: now,
                  minimumYear: 2020,
                  maximumYear: now.year,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Today reads in calm purple; a past day switches to amber so it's
      // obvious you're looking at history. On the coloured header it's a quiet
      // white metadata line — no chip, no glass, so it never competes with the
      // status hero below it.
      final color = onDark
          ? Colors.white
          : (controller.isToday ? _kPurple : _kAmber);
      final calendarIcon = Icon(Icons.calendar_today_rounded,
          size: onDark ? 16 : 14, color: color);
      final label = Text(
        controller.selectedDateLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.displaySmBold.copyWith(color: color, fontSize: 15),
      );
      final chevron = Icon(Icons.keyboard_arrow_down_rounded,
          size: onDark ? 20 : 18, color: color);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPicker(context),
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v == 0) return;
          // Drag toward the right → go back a day; toward the left → forward.
          _step(v > 0 ? -1 : 1);
        },
        // On the coloured header the date is a tappable *control*, so a quiet
        // pill gives it an affordance and keeps it legible — without the heavy
        // glass we removed from the status block below. It's given a comfortable
        // width (roughly the child's name above) with the chevron pushed to the
        // far edge so it reads as a proper selector, not a hugging tag.
        child: onDark
            ? Container(
                width: 188.w,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Row(
                  children: [
                    calendarIcon,
                    SizedBox(width: 8.w),
                    Flexible(child: label),
                    const Spacer(),
                    chevron,
                  ],
                ))
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    calendarIcon,
                    SizedBox(width: 8.w),
                    label,
                    SizedBox(width: 2.w),
                    chevron,
                  ],
                ),
              ),
      );
    });
  }
}

// ─── "Back to today" banner (shown only in History Mode) ─────────────────────

class _HistoryBanner extends StatelessWidget {
  const _HistoryBanner({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.backToToday,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: _kAmber.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kAmber.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 18.sp, color: _kAmber),
            SizedBox(width: 10.w),
            Expanded(
              child: Obx(() => Text(
                    'بتشوف يوم ${controller.selectedDateLabel}',
                    style: context.typography.displaySmBold.copyWith(color: _kInk, fontSize: 13),
                  )),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _kAmber,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'العودة لليوم',
                style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              )),
          ],
        ),
      ),
    );
  }
}

// ─── History recap Hero (premium "day summary") ──────────────────────────────

class _HistoryRecapHero extends StatelessWidget {
  const _HistoryRecapHero({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = controller;
      final hasData = c.hasDayData;
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPurpleDeep, _kPurple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: _kColoredShadow(_kPurple),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -20,
              child: _circle(120, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -40,
              right: -10,
              child: _circle(110, Colors.white.withValues(alpha: 0.06)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12.sp, color: Colors.white),
                        SizedBox(width: 6.w),
                        Text(
                          c.selectedDateFull,
                          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    )),
                  SizedBox(height: 14.h),
                  if (!hasData)
                    Row(
                      children: [
                        _glassIcon(Icons.event_busy_rounded),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'مفيش نشاط مسجّل في اليوم ده',
                            style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      c.recapHeadline,
                      style: context.typography.mdBold.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 16.h),
                    ..._statLines(c),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _statLines(ParentDashboardController c) {
    final ar = ParentDashboardController.ar;
    final lines = <_RecapStat>[];
    if (c.recapCheckIn.isNotEmpty) {
      lines.add(_RecapStat(
          icon: Icons.login_rounded, label: 'حضر', value: c.recapCheckIn));
    }
    if (c.recapActivities > 0) {
      lines.add(_RecapStat(
          icon: Icons.menu_book_rounded,
          label: 'أنشطة',
          value: ar('${c.recapActivities}')));
    }
    if (c.recapPhotos > 0) {
      lines.add(_RecapStat(
          icon: Icons.photo_camera_rounded,
          label: 'صور',
          value: ar('${c.recapPhotos}')));
    }
    if (c.recapMeals > 0) {
      lines.add(_RecapStat(
          icon: Icons.restaurant_menu_rounded,
          label: 'وجبات',
          value: ar('${c.recapMeals}')));
    }
    if (c.recapNaps > 0) {
      lines.add(_RecapStat(
          icon: Icons.bedtime_rounded,
          label: 'نوم',
          value: ar('${c.recapNaps}')));
    }
    if (c.recapNotes > 0) {
      lines.add(_RecapStat(
          icon: Icons.chat_bubble_rounded,
          label: 'ملاحظات',
          value: ar('${c.recapNotes}')));
    }
    if (c.recapCheckOut.isNotEmpty) {
      lines.add(_RecapStat(
          icon: Icons.logout_rounded, label: 'انصرف', value: c.recapCheckOut));
    }
    final out = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      if (i != 0) out.add(SizedBox(height: 11.h));
      out.add(lines[i]);
    }
    return out;
  }

  static Widget _circle(double d, Color col) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: col, shape: BoxShape.circle));
}

class _RecapStat extends StatelessWidget {
  const _RecapStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colors.white, size: 18.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: context.typography.smSemiBold.copyWith(color: Colors.white70, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ─── Teacher notes (History Mode only) ───────────────────────────────────────

class _HistoryNotesSection extends StatelessWidget {
  const _HistoryNotesSection({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notes = controller.dailyNotes;
      if (notes.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 0.h, 2.w, 12.h),
            child: _SectionHeader(
              icon: Icons.chat_bubble_rounded,
              title: 'ملاحظات المعلمة',
              accent: _kBlue,
            ),
          ),
          for (int i = 0; i < notes.length; i++) ...[
            if (i != 0) SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: _kCardShadow,
              ),
              child: Text(
                notes[i].text,
                style: context.typography.xsMedium.copyWith(color: _kInk, fontSize: 13, height: 1.4),
              )),
          ],
        ],
      );
    });
  }
}

// ─── Merged header + hero ─────────────────────────────────────────────────────
// No classic AppBar. The child IS the hero: avatar + name + classroom live at
// the very top, inside a full-bleed coloured card that runs up under the status
// bar. Notifications/settings/chat collapse into one quiet glass cluster so they
// never compete with the child. The whole thing reads as one premium header.

/// Inline WhatsApp glyph — rendered from a string (not an asset) so it appears
/// on a hot reload without needing the asset bundle to be rebuilt.
const String _kWhatsAppSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#000">'
    '<path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95'
    'L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21h.01c5.46 0 9.91-4.45 '
    '9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.82 9.82 0 0 0 12.04 2zm5.79 '
    '14.13c-.25.69-1.45 1.32-1.99 1.36-.51.05-1 .24-3.4-.71-2.86-1.13-4.67'
    '-4.06-4.81-4.25-.14-.18-1.15-1.53-1.15-2.92 0-1.39.73-2.07 .99-2.36'
    '.25-.28.55-.35.74-.35.18 0 .37 0 .53.01.17.01.4-.06.62.48.25.61 .85 '
    '2.11.92 2.26.07.15.12.32.02.51-.09.18-.14.3-.28.46-.14.16-.29.36-.42'
    '.48-.14.14-.28.29-.12.57.16.28.71 1.17 1.52 1.9 1.05.93 1.93 1.22 '
    '2.21 1.36.28.14.44.12.6-.07.18-.21.69-.81.88-1.09.18-.28.37-.23.62-.14'
    '.25.09 1.6.76 1.87.9.28.14.46.21.53.32.07.12.07.66-.18 1.35z"/></svg>';

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({
    required this.controller,
    required this.phase,
    required this.topInset,
    this.isHoliday = false,
  });
  final ParentDashboardController controller;
  final _Phase phase;
  final double topInset;
  final bool isHoliday;

  @override
  Widget build(BuildContext context) {
    final ({List<Color> grad, Color accent}) theme = isHoliday
        ? (
            grad: [const Color(0xFF6C4DDB), const Color(0xFF8B5CF6)],
            accent: const Color(0xFF6C4DDB)
          )
        : switch (phase) {
            _Phase.before => (grad: [_kPurple, _kPurpleDeep], accent: _kPurple),
            _Phase.during => (
                grad: [const Color(0xFF1E7A46), _kGreen],
                accent: _kGreen
              ),
            _Phase.after => (
                grad: [const Color(0xFF9A3412), _kAmber],
                accent: _kAmber
              ),
          };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.grad,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: _kColoredShadow(theme.grad.last),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            left: -20,
            child: _circle(130, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -40,
            right: -10,
            child: _circle(120, Colors.white.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, topInset + 12, 20.w, 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) WHO — child identity (avatar · name · class badge · icons).
                _identityRow(context),
                SizedBox(height: 14.h),
                // 2) WHEN — the day being viewed, as a tappable date control
                //    directly under the name.
                _HomeDateSubtitle(controller: controller, onDark: true),
                SizedBox(height: 18.h),
                // A faint divider sets the live "tracking" zone apart from the
                // identity/date zone above, so the status reads as its own block.
                Container(height: 1.h, color: Colors.white.withValues(alpha: 0.16)),
                SizedBox(height: 18.h),
                // 3) WHAT — the one question this header answers:
                //    "what is my child's state right now?" On a holiday there is
                //    no live state, so the hero says "اليوم إجازة" instead.
                isHoliday ? _holidayHero(context) : _statusHero(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityRow(BuildContext context) {
    return Obx(() {
      final name = controller.childName.isNotEmpty
          ? controller.childName
          : 'parent_default_name'.tr;
      final classroom = controller.classroomName;
      final hasSiblings = controller.siblings.length > 1;
      final activeId = controller.activeChildId;
      ActiveChildOption? active;
      for (final c in controller.siblings) {
        if (c.id == activeId) {
          active = c;
          break;
        }
      }
      return Row(
        children: [
          // Identity expands to fill the row, pushing the system-action cluster
          // to the opposite (far) edge instead of crowding the name.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hasSiblings
                  ? () => _showChildSwitcher(context, controller)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _avatar(active, name),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.typography.lgBold.copyWith(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.1),
                              ),
                            ),
                            if (hasSiblings)
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20.sp,
                                color: Colors.white),
                          ],
                        ),
                        if (classroom.isNotEmpty) ...[
                          SizedBox(height: 5.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              classroom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.displaySmBold.copyWith(color: Colors.white.withValues(alpha: 0.95), fontSize: 11, letterSpacing: 0.2),
                            )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          _iconCluster(context),
        ],
      );
    });
  }

  Widget _avatar(ActiveChildOption? child, String name) {
    final img = child?.image;
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (img != null && img.isNotEmpty)
          ? Image(
              image: appCachedImageProvider(img),
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              errorBuilder: (_, _, _) => _avatarInitial(name),
            )
          : _avatarInitial(name),
    );
  }

  Widget _avatarInitial(String name) => Text(
        name.isNotEmpty ? name.characters.first : '؟',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _iconCluster(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _glassAction(
            Icons.chat_rounded,
            openNurseryWhatsApp,
            svgString: _kWhatsAppSvg,
          ),
          _glassAction(
            Icons.notifications_none_rounded,
            () => Get.toNamed(notificationsView),
            badge: true,
          ),
          _glassAction(
            Icons.settings_outlined,
            () => Get.to(() => const ParentAccountView()),
          ),
        ],
      ),
    );
  }

  Widget _glassAction(IconData icon, VoidCallback onTap,
      {bool badge = false, String? svgString}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (svgString != null)
              SvgPicture.string(
                svgString,
                width: 21,
                height: 21,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
            else
              Icon(icon, size: 21.sp, color: Colors.white),
            if (badge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 7.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: _kRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  )),
              ),
          ],
        ),
      ),
    );
  }

  // ── The focused status hero ────────────────────────────────────────────────
  // Strict 3-level weight hierarchy so the eye lands once:
  //   Title (status)  ▸  Subtitle (what supports it)  ▸  Metadata (tiny facts)
  // Holiday replacement for the live status zone: no tracking, just a warm
  // "today is a day off" statement + the reason (specific label / weekly).
  Widget _holidayHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Icons.celebration_rounded,
              color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 13.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اليوم إجازة',
                style: context.typography.xsBold.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15),
              ),
              SizedBox(height: 5.h),
              Text(
                controller.holidayLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography.smSemiBold.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.5,
                    height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusHero(BuildContext context) {
    return Obx(() {
      final c = controller;
      final s = c.effectiveStatus;
      final firstName =
          c.childName.isNotEmpty ? c.childName.split(' ').first : 'طفلك';

      // ── Subtitle: the single supporting sentence for the current state ──
      String subtitle;
      switch (phase) {
        case _Phase.before:
          final first = c.firstLesson;
          subtitle = first != null
              ? 'أول حصة النهارده تبدأ ${c.fmtScheduleTime(first.startTime)}'
              : 'لسه اليوم الدراسي ما بدأش';
          break;
        case _Phase.during:
          if (c.statusUpdatedLabel.isNotEmpty) {
            subtitle = c.statusUpdatedLabel;
          } else {
            final next = c.nextLesson;
            subtitle = next != null
                ? 'اللي جاي · ${c.scheduleLabel(next)} ${c.fmtScheduleTime(next.startTime)}'
                : '$firstName داخل الحضانة دلوقتي';
          }
          break;
        case _Phase.after:
          subtitle = s.isOnBus
              ? '$firstName في الطريق للبيت'
              : 'انتهى اليوم الدراسي · يومه كان جميل';
          break;
      }

      // ── Metadata: tiny plain facts (icon + text). No chips, no glass. ──
      // Only show "arrived at" once the child is actually inside — never
      // alongside "لم يصل بعد".
      final meta = <({IconData icon, String text})>[];
      if (s.isActive && c.realCheckInTime != '--:--') {
        meta.add((
          icon: Icons.login_rounded,
          text: 'وصل ${ParentDashboardController.ar(c.realCheckInTime)}',
        ));
      }
      if (phase == _Phase.during && c.liveStateSinceLabel.isNotEmpty) {
        meta.add((
          icon: Icons.hourglass_bottom_rounded,
          text: c.liveStateSinceLabel,
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE — the hero. A real status icon fronts it (the app font has no
          // emoji glyphs, so an Icon reads cleanly instead of a tofu box).
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(s.icon, color: Colors.white, size: 27.sp),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  s.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsBold.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.15),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          // SUBTITLE — supporting context, clearly lighter than the title.
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold.copyWith(color: Colors.white.withValues(alpha: 0.82), fontSize: 13.5, height: 1.3),
          ),
          if (meta.isNotEmpty) ...[
            SizedBox(height: 11.h),
            // METADATA — the quietest line in the header.
            Row(
              children: [
                for (var i = 0; i < meta.length; i++) ...[
                  if (i > 0) SizedBox(width: 14.w),
                  Icon(meta[i].icon,
                      size: 13.sp, color: Colors.white.withValues(alpha: 0.6)),
                  SizedBox(width: 5.w),
                  Text(
                    meta[i].text,
                    style: context.typography.smSemiBold.copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
          ..._heroAction(context, firstName),
        ],
      );
    });
  }

  // A single, optional action — only when the state invites one. It's an
  // action (a button), never another competing piece of information.
  List<Widget> _heroAction(BuildContext context, String firstName) {
    if (phase == _Phase.during) {
      return [
        SizedBox(height: 16.h),
        _HeroCtaButton(
          icon: Icons.directions_car_rounded,
          label: controller.pickupRequested.value
              ? 'تم إرسال طلب الاستلام'
              : 'اطلب استلام $firstName',
          onTap: () => _showPickupSheet(context, controller),
        ),
      ];
    }
    if (phase == _Phase.after && controller.effectiveStatus.isOnBus) {
      return [
        SizedBox(height: 16.h),
        _HeroCtaButton(
          icon: Icons.location_on_rounded,
          label: 'تتبّع $firstName على الخريطة',
          onTap: () => _showTrackMapSheet(context, controller),
        ),
      ];
    }
    return const [];
  }

  static Widget _circle(double d, Color c) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

// ─── White-glass CTA used inside the gradient hero ───────────────────────────

class _HeroCtaButton extends StatelessWidget {
  const _HeroCtaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: _kInk),
            SizedBox(width: 8.w),
            Text(
              label,
              style: context.typography.displaySmBold.copyWith(color: _kInk, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        )),
    );
  }
}

Widget _glassIcon(IconData icon) => Container(
      width: 46.w,
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(icon, color: Colors.white, size: 24.sp));

// ─── "محتاج انتباهك" merged priority strip ───────────────────────────────────

/// A small rounded count/label chip used inside section headers.
class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: context.typography.displaySmBold.copyWith(color: color, fontSize: 12.5, fontWeight: FontWeight.w800),
      ));
  }
}

/// One consistent header for every section on the home: a tinted icon tile,
/// a strong title (with an optional inline count pill + subtitle) and an
/// optional trailing action on the far side. Unifies the rhythm + typography
/// across the timeline / photos / inbox blocks.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.pill,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? pill;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(icon, size: 18.sp, color: accent)),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.mdBold.copyWith(color: _kInk, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                  ),
                  if (pill != null) ...[
                    SizedBox(width: 8.w),
                    pill!,
                  ],
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsMedium.copyWith(color: _kMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.w),
          trailing!,
        ],
      ],
    );
  }
}

class _AttentionStrip extends StatelessWidget {
  const _AttentionStrip({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final c = controller;
    final ar = ParentDashboardController.ar;
    final items = <Widget>[];

    // ── 1) Overdue / pending fees (informational only — no pay button) ──
    for (final inv in c.pendingInvoices) {
      final overdue = inv.status == 'overdue';
      final amount = ar(inv.totalAmount.toStringAsFixed(0));
      final isFee = inv.key?.startsWith('fee_') == true;
      final due = isFee ? '' : _fmtInboxDate(inv.dueDate);
      items.add(_InboxItem(
        color: overdue ? _kRed : _kAmber,
        icon: Icons.payments_rounded,
        title: inv.title?.isNotEmpty == true
            ? inv.title!
            : (inv.categoryName?.isNotEmpty == true
                ? inv.categoryName!
                : 'رسوم مستحقة'),
        sub: due.isNotEmpty
            ? '$amount ج.م · آخر موعد $due'
            : '$amount ج.م',
        subIsAlert: overdue,
        onTap: () => Get.toNamed(parentInvoicesView),
      ));
    }

    // ── 2) Required homework ──
    final hw = c.pendingHomework;
    if (hw.isNotEmpty) {
      items.add(_InboxItem(
        color: _kAmber,
        icon: Icons.assignment_rounded,
        title: 'واجبات مطلوبة',
        badge: hw.length,
        lines: [
          for (final h in hw)
            _InboxLine(
              subject: h.subjectKey.isNotEmpty ? h.subjectKey : null,
              text: h.displayTitle?.isNotEmpty == true
                  ? h.displayTitle!
                  : h.titleKey,
            ),
        ],
        onTap: () => Get.find<MainPageViewModel>().changePage(1),
      ));
    }

    // ── 3) Teacher notes ──
    final notes = c.dailyNotes;
    if (notes.isNotEmpty) {
      items.add(_InboxItem(
        color: _kBlue,
        icon: Icons.chat_bubble_rounded,
        title: 'ملاحظات المعلمة',
        badge: notes.length,
        lines: [for (final n in notes) _InboxLine(text: n.text)],
        onTap: () => Get.find<MainPageViewModel>().changePage(1),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(2.w, 0.h, 2.w, 12.h),
          child: _SectionHeader(
            icon: Icons.inbox_rounded,
            title: 'محتاج انتباهك',
            accent: _kAmber,
            trailing: _CountBadge(count: items.length),
          ),
        ),
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) SizedBox(height: 10.h),
          items[i],
        ],
      ],
    );
    });
  }
}

// "1716163200000" → "25 مايو"
String _fmtInboxDate(int? ms) {
  if (ms == null) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  return '${ParentDashboardController.ar('${dt.day}')} ${months[dt.month - 1]}';
}

class _InboxLine {
  const _InboxLine({this.subject, required this.text});
  final String? subject;
  final String text;
}

class _InboxItem extends StatelessWidget {
  const _InboxItem({
    required this.color,
    required this.icon,
    required this.title,
    this.sub,
    this.subIsAlert = false,
    this.badge,
    this.lines = const [],
    this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String? sub;
  final bool subIsAlert;
  final int? badge;
  final List<_InboxLine> lines;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: _kCardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // colored status bar
            Container(
              width: 5.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(16.r),
                ),
              )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── header row ──────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.h,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: Icon(icon, color: color, size: 19.sp)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.displaySmBold.copyWith(color: _kInk, fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                              if (badge != null) ...[
                                SizedBox(width: 7.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    '$badge',
                                    style: context.typography.displaySmBold.copyWith(color: color, fontSize: 12, fontWeight: FontWeight.w800),
                                  )),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // reversed arrow (points the other way now)
                        Icon(Icons.chevron_right_rounded,
                            color: _kMuted, size: 22.sp),
                      ],
                    ),
                    // ── single subtitle ─────────────────────────────────
                    if (sub != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        sub!,
                        style: context.typography.displaySmBold.copyWith(color: subIsAlert ? _kRed : _kMuted, fontSize: 12.5),
                      ),
                    ],
                    // ── multiple lines (homework / notes) ────────────────
                    if (lines.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      for (int i = 0; i < lines.length; i++) ...[
                        if (i != 0) SizedBox(height: 8.h),
                        _InboxSubRow(line: lines[i], color: color),
                      ],
                    ],
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

class _InboxSubRow extends StatelessWidget {
  const _InboxSubRow({required this.line, required this.color});
  final _InboxLine line;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 5.h),
          width: 5.w,
          height: 5.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        if (line.subject != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              line.subject!,
              style: context.typography.displaySmBold.copyWith(color: color, fontSize: 11.5, fontWeight: FontWeight.w800),
            )),
          SizedBox(width: 7.w),
        ],
        Expanded(
          child: Text(
            line.text,
            style: context.typography.xsMedium.copyWith(color: _kInk, fontSize: 13.5, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: _kAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '$count',
          style: context.typography.displaySmBold.copyWith(color: _kAmber, fontSize: 13, fontWeight: FontWeight.w800),
        ));
}

// ─── "خط اليوم" compact timeline preview ─────────────────────────────────────

class _TodayTimelinePreview extends StatelessWidget {
  const _TodayTimelinePreview({required this.controller, this.history = false});
  final ParentDashboardController controller;

  /// Past-day mode: hide live bits (running activity, next lesson, today's
  /// full-schedule link) and reword the empty/header copy.
  final bool history;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final c = controller;

    // 1) Journal events (what already happened) — chronological.
    final events = c.todayTimeline2.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final specs = <_TLSpec>[for (final e in events) _specFromEvent(c, e)];

    // 2) The live classroom activity (running now) — only if not already
    //    represented by a completed journal entry. (today only, and only once
    //    the child has arrived — the track starts at check-in.)
    final running =
        (history || !c.isChildActive) ? null : c.runningClassroomActivity.value;
    if (running != null && running.isActive) {
      final already = running.key != null &&
          specs.any((s) => s.activityId == running.key);
      if (!already) {
        final subj = running.subjectName ?? '';
        specs.add(_TLSpec(
          time: c.fmtClockMs(running.startedAt),
          icon: Icons.menu_book_rounded,
          title: subj.isNotEmpty ? '$subj — ${running.title}' : running.title,
          caption: 'نشاط الفصل الحالي',
          kind: _TLKind.academic,
          state: _TLState.current,
          activityId: running.key,
        ));
      }
    }

    // 3) Next scheduled lesson (what's coming) — upcoming. (today only)
    final next = history ? null : c.nextLesson;
    if (next != null) {
      specs.add(_TLSpec(
        time: c.fmtScheduleTime(next.startTime),
        icon: Icons.schedule_rounded,
        title: c.scheduleLabel(next),
        caption: 'الحصة الجاية',
        kind: _TLKind.academic,
        state: _TLState.upcoming,
      ));
    }

    final doneCount = specs.where((s) => s.state == _TLState.done).length;

    // On the live home keep the timeline compact: show only the 2 most recent
    // entries; the full day opens in the dedicated schedule screen.
    final collapsed = !history && specs.length > 2;
    final shownSpecs = collapsed ? specs.sublist(specs.length - 2) : specs;
    final hiddenCount = specs.length - shownSpecs.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Prominent header ───────────────────────────────────────
          _SectionHeader(
            icon: Icons.timeline_rounded,
            title: 'خط اليوم',
            accent: _kPurple,
            subtitle:
                history ? 'كل اللي حصل في اليوم ده' : 'كل اللي حصل ولسه جاي',
            trailing: specs.isEmpty
                ? null
                : _MiniPill(
                    label: '${ParentDashboardController.ar('$doneCount')} / '
                        '${ParentDashboardController.ar('${specs.length}')}',
                    color: _kPurple,
                  ),
          ),
          SizedBox(height: 16.h),
          if (specs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Text(
                  history ? 'مفيش أحداث في اليوم ده' : 'لسه مفيش أحداث النهارده',
                  style: context.typography.smSemiBold.copyWith(color: _kMuted, fontSize: 12.5),
                ),
              ),
            )
          else ...[
            for (int i = 0; i < shownSpecs.length; i++)
              _TLItem(
                time: shownSpecs[i].time,
                icon: shownSpecs[i].icon,
                title: shownSpecs[i].title,
                caption: shownSpecs[i].caption,
                kind: shownSpecs[i].kind,
                state: shownSpecs[i].state,
                isLast: i == shownSpecs.length - 1,
                onTap: shownSpecs[i].activityId != null
                    ? () => _openActivity(context, c, shownSpecs[i].activityId!)
                    : null,
              ),
            if (!history) ...[
              SizedBox(height: 4.h),
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(parentTodayScheduleView),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _kPurple.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          collapsed
                              ? 'عرض المزيد (${ParentDashboardController.ar('$hiddenCount')})'
                              : 'عرض جدول اليوم الكامل',
                          style: context.typography.displaySmBold.copyWith(color: _kPurple, fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.chevron_right_rounded,
                            size: 18.sp, color: _kPurple),
                      ],
                    )),
                ),
              ),
            ],
          ],
        ],
      ),
    );
    });
  }
}

// ── Timeline spec — one row derived from a real journal event ────────────────

class _TLSpec {
  _TLSpec({
    required this.time,
    required this.icon,
    required this.title,
    required this.caption,
    required this.kind,
    required this.state,
    this.activityId,
  });
  final String time;
  final IconData icon;
  final String title;
  final String caption;
  final _TLKind kind;
  final _TLState state;
  final String? activityId;
}

String _mealCaption(ChildDailyEventModel e) {
  final s = switch (e.mealStatus) {
    'ate_all' => 'أكل كل الوجبة',
    'ate_half' => 'أكل نص الوجبة',
    'refused' => 'رفض الأكل',
    _ => null,
  };
  return s != null ? 'رعاية · $s' : 'رعاية';
}

_TLSpec _specFromEvent(ParentDashboardController c, ChildDailyEventModel e) {
  final time = c.fmtClockMs(e.createdAt);
  switch (e.eventType) {
    case ChildEventType.checkIn:
      return _TLSpec(
        time: time,
        icon: Icons.login_rounded,
        title: e.title ?? 'سجّل الحضور',
        caption: 'حضور',
        kind: _TLKind.attendance,
        state: _TLState.done,
      );
    case ChildEventType.checkOut:
      return _TLSpec(
        time: time,
        icon: Icons.logout_rounded,
        title: e.title ?? 'انصرف',
        caption: 'انصراف',
        kind: _TLKind.attendance,
        state: _TLState.done,
      );
    case ChildEventType.mealStarted:
    case ChildEventType.mealCompleted:
      return _TLSpec(
        time: time,
        icon: Icons.restaurant_menu_rounded,
        title: e.title ?? 'وجبة',
        caption: _mealCaption(e),
        kind: _TLKind.care,
        state: _TLState.done,
      );
    case ChildEventType.napStarted:
    case ChildEventType.napCompleted:
      return _TLSpec(
        time: time,
        icon: Icons.bedtime_rounded,
        title: e.title ?? 'القيلولة',
        caption: 'نوم',
        kind: _TLKind.sleep,
        state: _TLState.done,
      );
    case ChildEventType.bathroom:
      return _TLSpec(
        time: time,
        icon: Icons.wc_rounded,
        title: e.title ?? 'دخل الحمام',
        caption: 'رعاية',
        kind: _TLKind.care,
        state: _TLState.done,
      );
    case ChildEventType.activityStarted:
    case ChildEventType.activityCompleted:
      final subj = e.subjectName ?? '';
      return _TLSpec(
        time: time,
        icon: Icons.menu_book_rounded,
        title: e.title ?? (subj.isNotEmpty ? subj : 'نشاط الفصل'),
        caption: 'نشاط الفصل',
        kind: _TLKind.academic,
        state: _TLState.done,
        activityId: e.activityId,
      );
    case ChildEventType.childStateChanged:
      return _TLSpec(
        time: time,
        icon: Icons.child_care_rounded,
        title: e.title ?? 'تغيّرت حالته',
        caption: 'حالة الطفل',
        kind: _TLKind.childState,
        state: _TLState.done,
      );
    case ChildEventType.noteAdded:
      return _TLSpec(
        time: time,
        icon: Icons.chat_bubble_rounded,
        title: e.title ?? 'ملاحظة من المعلمة',
        caption: 'ملاحظة',
        kind: _TLKind.care,
        state: _TLState.done,
      );
    case ChildEventType.medicineGiven:
      return _TLSpec(
        time: time,
        icon: Icons.medical_services_rounded,
        title: e.title ?? 'أخذ الدواء',
        caption: 'رعاية',
        kind: _TLKind.care,
        state: _TLState.done,
      );
    case ChildEventType.busBoarded:
      return _TLSpec(
        time: time,
        icon: Icons.directions_bus_rounded,
        title: e.title ?? 'ركب الباص',
        caption: 'الباص',
        kind: _TLKind.attendance,
        state: _TLState.done,
      );
    case ChildEventType.busArrived:
      return _TLSpec(
        time: time,
        icon: Icons.location_on_rounded,
        title: e.title ?? 'وصل الباص',
        caption: 'الباص',
        kind: _TLKind.attendance,
        state: _TLState.done,
      );
    case ChildEventType.homeworkAssigned:
      return _TLSpec(
        time: time,
        icon: Icons.assignment_rounded,
        title: e.title ?? 'واجب جديد',
        caption: 'واجب',
        kind: _TLKind.academic,
        state: _TLState.done,
      );
    case ChildEventType.pickupRequested:
      return _TLSpec(
        time: time,
        icon: Icons.directions_car_rounded,
        title: e.title ?? 'طلب استلام',
        caption: 'استلام',
        kind: _TLKind.care,
        state: _TLState.done,
      );
    default:
      return _TLSpec(
        time: time,
        icon: Icons.fiber_manual_record_rounded,
        title: e.title ?? 'حدث',
        caption: e.description ?? '',
        kind: _TLKind.care,
        state: _TLState.done,
      );
  }
}

/// Fetch the full activity for [activityId] then open the detail sheet.
Future<void> _openActivity(
  BuildContext context,
  ParentDashboardController c,
  String activityId,
) async {
  final activity = await c.activityById(activityId);
  if (activity == null || !context.mounted) return;
  _showActivitySheet(context, _detailFromActivity(c, activity));
}

/// Build the rich activity-detail view-model from a real ClassroomActivity.
_ActivityDetail _detailFromActivity(
  ParentDashboardController c,
  ClassroomActivityModel a,
) {
  final subj = a.subjectName ?? '';
  final title = subj.isNotEmpty ? '$subj — ${a.title}' : a.title;
  final childId = c.activeChildId;
  final eval = a.evalFor(childId);

  int rating = 0;
  String ratingLabel;
  if (a.isActive) {
    ratingLabel = 'النشاط لسه شغّال — التقييم بعد ما يخلص';
  } else if (eval == null) {
    ratingLabel = 'لم يتم التقييم بعد';
  } else {
    rating = switch (eval) {
      EvalLevel.excellent => 5,
      EvalLevel.needsFollow => 3,
      EvalLevel.needsAttention => 1,
    };
    ratingLabel = switch (eval) {
      EvalLevel.excellent => 'ممتاز',
      EvalLevel.needsFollow => 'يحتاج متابعة',
      EvalLevel.needsAttention => 'يحتاج اهتمام',
    };
  }

  final reasons = a.childReasons[childId] ?? const <String>[];
  final freeNote = a.notes[childId]?.trim();
  // The teacher's per-child comment can live in three places depending on how
  // it was entered: a free-text note, structured evaluation reasons, or the
  // parent-visible notes feed (where the end-activity flow fans it out). Prefer
  // the richest available so it never silently disappears from the sheet.
  final childNote = (freeNote != null && freeNote.isNotEmpty)
      ? freeNote
      : (reasons.isNotEmpty
          ? reasons.join('، ')
          : c.teacherNoteForActivity(a.key ?? ''));
  final groupNote = a.groupNote?.trim();
  final description = 'نشاط $title';

  return _ActivityDetail(
    title: title,
    time: c.activityTimeRange(a),
    icon: Icons.menu_book_rounded,
    accent: _kBlue,
    description: description,
    rating: rating,
    ratingLabel: ratingLabel,
    childName: c.childName,
    childNote: (childNote?.isNotEmpty == true) ? childNote : null,
    groupNote: (groupNote?.isNotEmpty == true) ? groupNote : null,
    photoUrls: a.photos.values.toList(),
  );
}

enum _TLState { done, current, upcoming }

// Event categories — each gets its own colour so the parent can tell
// at a glance: teaching vs. live child-state vs. care vs. sleep.
enum _TLKind { academic, childState, care, sleep, attendance }

const _kSky = Color(0xFF0891B2);

Color _kindColor(_TLKind k) => switch (k) {
      _TLKind.academic => _kBlue,
      _TLKind.childState => _kGreen,
      _TLKind.care => _kSky,
      _TLKind.sleep => _kPurple,
      _TLKind.attendance => const Color(0xFF059669),
    };

/// Whole-card tap target with a subtle press-down scale so the entire
/// event card feels tappable (not just the "التفاصيل" chip). When [onTap]
/// is null the card is inert and shows no press feedback.
class _PressableCard extends StatefulWidget {
  const _PressableCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null || _pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _TLItem extends StatelessWidget {
  const _TLItem({
    required this.time,
    required this.title,
    required this.icon,
    required this.caption,
    required this.kind,
    required this.state,
    this.isLast = false,
    this.onTap,
  });
  final String time;
  final String title;
  final String caption;
  final IconData icon;
  final _TLKind kind;
  final _TLState state;
  final bool isLast;

  /// When present the event card becomes tappable and opens a rich
  /// activity sheet (description + photos + rating + teacher note).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _kindColor(kind);
    final isCurrent = state == _TLState.current;
    final isUpcoming = state == _TLState.upcoming;
    final tappable = onTap != null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40.w,
            child: Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                time,
                style: context.typography.displaySmBold.copyWith(color: isCurrent ? accent : _kMuted, fontSize: 12.5, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600),
              ),
            )),
          SizedBox(width: 8.w),
          // ── spine ───────────────────────────────────────────────────
          Column(
            children: [
              SizedBox(height: 8.h),
              _dot(accent),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: isUpcoming
                        ? const Color(0xFFE2E8F0)
                        : accent.withValues(alpha: 0.25)),
                ),
            ],
          ),
          SizedBox(width: 10.w),
          // ── tinted event card ───────────────────────────────────────
          Expanded(
            child: _PressableCard(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isUpcoming ? 0.05 : 0.09),
                  borderRadius: BorderRadius.circular(13.r),
                  border: isCurrent
                      ? Border.all(color: accent.withValues(alpha: 0.4))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color:
                            accent.withValues(alpha: isUpcoming ? 0.12 : 0.18),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Icon(icon,
                          size: 16.sp,
                          color: isUpcoming
                              ? accent.withValues(alpha: 0.7)
                              : accent)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.displaySmBold.copyWith(color: isUpcoming ? _kMuted : _kInk, fontSize: 14, fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            caption,
                            style: context.typography.displaySmBold.copyWith(color: accent.withValues(alpha: isUpcoming ? 0.7 : 1), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'الآن',
                          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                        ))
                    else if (tappable)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'التفاصيل',
                              style: context.typography.displaySmBold.copyWith(color: accent, fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(width: 2.w),
                            Icon(Icons.chevron_right_rounded,
                                size: 18.sp, color: accent),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color accent) {
    switch (state) {
      case _TLState.done:
        return Container(
          width: 14.w,
          height: 14.h,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, color: Colors.white, size: 9.sp));
      case _TLState.current:
        return Container(
          width: 14.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.3), width: 3),
          ));
      case _TLState.upcoming:
        return Container(
          width: 14.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
          ));
    }
  }
}

// ─── Photos strip (small, tasteful) ──────────────────────────────────────────

class _PhotosStrip extends StatefulWidget {
  const _PhotosStrip({required this.controller});
  final ParentDashboardController controller;

  @override
  State<_PhotosStrip> createState() => _PhotosStripState();
}

class _PhotosStripState extends State<_PhotosStrip> {
  int _featured = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photos = widget.controller.todayPhotos;
      if (photos.isEmpty) return const SizedBox.shrink();
      // Keep the featured index valid if the photo list changes.
      final featured = _featured.clamp(0, photos.length - 1);
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kCardRadius),
          boxShadow: _kCardShadow,
        ),
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header ───────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.photo_library_rounded,
              title: 'صور اليوم',
              accent: _kPurple,
              pill: _MiniPill(
                label: ParentDashboardController.ar('${photos.length}'),
                color: _kPurple,
              ),
              trailing: GestureDetector(
                onTap: () => Get.toNamed(
                  parentClassPhotosView,
                  arguments: {
                    'urls': photos.toList(),
                    'classroomName': widget.controller.classroomName,
                  },
                ),
                child: Text(
                  'عرض الكل',
                  style: context.typography.displaySmBold.copyWith(color: _kPurple, fontSize: 13),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // ── featured (big) photo ─────────────────────────────────
            GestureDetector(
              onTap: () => _showPhotoViewer(context, photos, featured),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 210.h,
                  child: Image(
                    image: appCachedImageProvider(photos[featured]),
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) => prog == null
                        ? child
                        : Container(color: const Color(0xFFE2E8F0)),
                    errorBuilder: (ctx, _, _) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: Icon(Icons.broken_image_rounded,
                          color: _kMuted, size: 28.sp)),
                  ),
                ),
              ),
            ),
            // ── thumbnail strip (only when there's more than one) ────
            if (photos.length > 1) ...[
              SizedBox(height: 10.h),
              SizedBox(
                height: 64.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final active = i == featured;
                    return GestureDetector(
                      onTap: () => setState(() => _featured = i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: 64.w,
                          height: 64.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: active ? _kPurple : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          foregroundDecoration: active
                              ? null
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                          child: Image(
                            image: appCachedImageProvider(photos[i]),
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, prog) => prog == null
                                ? child
                                : Container(color: const Color(0xFFE2E8F0)),
                            errorBuilder: (ctx, _, _) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: Icon(Icons.broken_image_rounded,
                                  color: _kMuted, size: 20.sp)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// Simple full-screen photo viewer (tap a thumbnail).
void _showPhotoViewer(BuildContext context, List<String> urls, int initial) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (_) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 12.w),
        child: PageView.builder(
          controller: PageController(initialPage: initial),
          itemCount: urls.length,
          itemBuilder: (_, i) => InteractiveViewer(
            child: Center(
              child: Image(image: appCachedImageProvider(urls[i]), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  Activity detail — turns a timeline log entry into a story (Journey)
// ═══════════════════════════════════════════════════════════════════════════

class _ActivityDetail {
  const _ActivityDetail({
    required this.title,
    required this.time,
    required this.icon,
    required this.accent,
    required this.description,
    required this.rating,
    required this.ratingLabel,
    required this.childName,
    required this.childNote,
    required this.groupNote,
    required this.photoUrls,
  });

  final String title;
  final String time;
  final IconData icon;
  final Color accent;
  final String description;

  /// 0 means "not rated yet" (activity still running / upcoming).
  final int rating;
  final String ratingLabel;
  final String childName;

  /// Teacher's note specific to this child (null when none was written).
  final String? childNote;

  /// Teacher's note for the whole class (null when none was written).
  final String? groupNote;
  final List<String> photoUrls;
}

void _showActivitySheet(BuildContext context, _ActivityDetail d) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ActivitySheet(detail: d),
  );
}

class _ActivitySheet extends StatefulWidget {
  const _ActivitySheet({required this.detail});
  final _ActivityDetail detail;

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;        // overall scrim/content fade
  late final Animation<double> _rise;        // whole sheet rises with overshoot
  late final Animation<double> _scale;       // whole sheet scales up (overshoot)
  late final Animation<double> _iconPop;     // icon bounces in (elastic)
  late final Animation<double> _iconSpin;    // icon spins as it lands
  late final Animation<double> _headerSlide; // title text slides in

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _rise = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));
    _iconPop = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    );
    _iconSpin = Tween<double>(begin: -0.6, end: 0.0).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
    ));
    _headerSlide = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    );
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// One staggered fade + slide-up + scale for a body section [index].
  Widget _stagger(int index, Widget child) {
    final start = (0.35 + index * 0.1).clamp(0.0, 0.85);
    final anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (_, w) {
        final t = anim.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0.w, 36 * (1 - t)),
            child: Transform.scale(
              scale: 0.92 + 0.08 * t,
              alignment: Alignment.topCenter,
              child: w,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final rated = d.rating > 0;
    final screenH = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: _entrance,
        builder: (_, sheet) {
          final rise = (1 - _rise.value) * screenH * 0.55;
          return Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0.w, rise),
              child: Transform.scale(
                scale: _scale.value,
                alignment: Alignment.bottomCenter,
                child: sheet,
              ),
            ),
          );
        },
        child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
          boxShadow: [
            BoxShadow(
              color: d.accent.withValues(alpha: 0.28),
              blurRadius: 40.r,
              spreadRadius: 2.r,
              offset: Offset(0.w, -6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4.r),
              )),
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _iconPop,
                    child: RotationTransition(
                    turns: _iconSpin,
                    child: Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: d.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(d.icon, color: d.accent, size: 24.sp)),
                  ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _headerSlide,
                      builder: (_, w) => Opacity(
                        opacity: _headerSlide.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(24 * (1 - _headerSlide.value), 0.h),
                          child: w,
                        ),
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: context.typography.mdBold.copyWith(color: _kInk, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 13.sp, color: _kMuted),
                            SizedBox(width: 4.w),
                            Text(
                              d.time,
                              style: context.typography.smSemiBold.copyWith(color: _kMuted, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 0.h, 18.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Description ────────────────────────────────────
                    _stagger(
                      0,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActivitySection(
                            icon: Icons.notes_rounded,
                            label: 'النشاط',
                            accent: d.accent,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              d.description,
                              style: context.typography.xsMedium.copyWith(color: _kInk, fontSize: 13, height: 1.7),
                            )),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // ── Photos ─────────────────────────────────────────
                    if (d.photoUrls.isNotEmpty) ...[
                      _stagger(
                        1,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ActivitySection(
                              icon: Icons.photo_library_rounded,
                              label: 'صور النشاط',
                              accent: d.accent,
                              trailing:
                                  '${ParentDashboardController.ar('${d.photoUrls.length}')} صور',
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              height: 104.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: d.photoUrls.length,
                                separatorBuilder: (_, _) =>
                                    SizedBox(width: 10.w),
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () =>
                                      _showPhotoViewer(context, d.photoUrls, i),
                                  child: _ActivityPhoto(url: d.photoUrls[i]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                    ],

                    // ── Child rating ───────────────────────────────────
                    _stagger(
                      2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActivitySection(
                            icon: Icons.star_rounded,
                            label: 'التقييم في النشاط',
                            accent: d.accent,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    final filled = rated && i < d.rating;
                                    return Padding(
                                      padding: EdgeInsets.only(left: 2.w),
                                      child: Icon(
                                        filled
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 22.sp,
                                        color: filled
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFCBD5E1)),
                                    );
                                  }),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    d.ratingLabel,
                                    style: context.typography.displaySmBold.copyWith(color: rated ? _kInk : _kMuted, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // ── Teacher notes ──────────────────────────────────
                    _stagger(
                      3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActivitySection(
                            icon: Icons.chat_bubble_rounded,
                            label: 'ملاحظات المعلمة',
                            accent: d.accent,
                          ),
                          SizedBox(height: 8.h),
                          if (d.childNote == null && d.groupNote == null)
                            _NoteCard(
                              text: 'مفيش ملاحظة خاصة على النشاط ده.',
                              accent: d.accent,
                            ),
                          if (d.childNote != null) ...[
                            _NoteCard(
                              text: d.childNote!,
                              accent: d.accent,
                              label: 'ملاحظة خاصة بـ${d.childName}',
                              icon: Icons.person_rounded,
                            ),
                            if (d.groupNote != null)
                              SizedBox(height: 10.h),
                          ],
                          if (d.groupNote != null)
                            _NoteCard(
                              text: d.groupNote!,
                              accent: _kSky,
                              label: 'ملاحظة عامة للفصل',
                              icon: Icons.groups_rounded,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Close button ─────────────────────────────────────────
            _stagger(
              4,
              Padding(
              padding: EdgeInsets.fromLTRB(
                  18.w, 8.h, 18.w, 14 + MediaQuery.of(context).viewPadding.bottom),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: d.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'تمام',
                    style: context.typography.displaySmBold.copyWith(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ),
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

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.icon,
    required this.label,
    required this.accent,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final Color accent;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: accent),
        SizedBox(width: 6.w),
        Text(
          label,
          style: context.typography.displaySmBold.copyWith(color: _kInk, fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: context.typography.displaySmBold.copyWith(color: _kMuted, fontSize: 11),
          ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.text,
    required this.accent,
    this.label,
    this.icon,
  });
  final String text;
  final Color accent;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Icon(icon ?? Icons.label_rounded, size: 14.sp, color: accent),
                SizedBox(width: 6.w),
                Text(
                  label!,
                  style: context.typography.displaySmBold.copyWith(color: accent, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, size: 18.sp, color: accent),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  text,
                  style: context.typography.smSemiBold.copyWith(color: _kInk, fontSize: 13, height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ));
  }
}

class _ActivityPhoto extends StatelessWidget {
  const _ActivityPhoto({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: 104.w,
        height: 104.h,
        child: Image(
          image: appCachedImageProvider(url),
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, prog) => prog == null
              ? child
              : Container(color: const Color(0xFFE2E8F0)),
          errorBuilder: (ctx, _, _) => Container(
            color: const Color(0xFFE2E8F0),
            child: Icon(Icons.broken_image_rounded,
                color: _kMuted, size: 26.sp)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Bottom sheets — pickup request & live track map
// ═══════════════════════════════════════════════════════════════════════════

void _showPickupSheet(
    BuildContext context, ParentDashboardController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickupSheet(controller: controller),
  );
}

class _PickupSheet extends StatefulWidget {
  const _PickupSheet({required this.controller});
  final ParentDashboardController controller;
  @override
  State<_PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<_PickupSheet> {
  String? _eta;
  static const _options = ['١٠ دقايق', '١٥ دقيقة', '٢٠ دقيقة', '٣٠ دقيقة'];

  @override
  Widget build(BuildContext context) {
    final firstName = widget.controller.childName.isNotEmpty
        ? widget.controller.childName.split(' ').first
        : 'طفلك';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4.r),
                )),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _kPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car_rounded,
                      color: _kPurple, size: 26.sp)),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب استلام $firstName',
                      style: context.typography.mdBold.copyWith(color: _kInk, fontSize: 16),
                    ),
                    Text(
                      'اختر وقت وصولك المتوقع',
                      style: context.typography.xsRegular.copyWith(color: _kMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _options.map((eta) {
                final sel = _eta == eta;
                return GestureDetector(
                  onTap: () => setState(() => _eta = eta),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                        horizontal: 22.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: sel ? _kPurple : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: sel ? _kPurple : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 15.sp,
                            color: sel ? Colors.white : _kMuted),
                        SizedBox(width: 6.w),
                        Text(
                          eta,
                          style: context.typography.smSemiBold.copyWith(color: sel ? Colors.white : _kInk, fontSize: 14),
                        ),
                      ],
                    )),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: _kGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: _kGreen, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'هيتبلّغ الاستقبال بموعد وصولك عشان يجهّزوا $firstName',
                      style: context.typography.xsRegular.copyWith(color: Color(0xFF065F46), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              )),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: _eta != null ? 1 : 0.45,
                duration: const Duration(milliseconds: 180),
                child: ElevatedButton.icon(
                  onPressed: _eta == null
                      ? null
                      : () {
                          widget.controller.requestPickup(_eta!);
                          Navigator.pop(context);
                        },
                  icon: Icon(Icons.send_rounded, size: 18.sp),
                  label: Text(
                    _eta != null ? 'هوصل خلال $_eta' : 'اختر وقت الوصول أولاً',
                    style: context.typography.displaySmBold.copyWith(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kPurple,
                    disabledForegroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

void _showTrackMapSheet(
    BuildContext context, ParentDashboardController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TrackMapSheet(controller: controller),
  );
}

class _TrackMapSheet extends StatelessWidget {
  const _TrackMapSheet({required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final firstName = controller.childName.isNotEmpty
        ? controller.childName.split(' ').first
        : 'طفلك';
    final h = MediaQuery.of(context).size.height * 0.62;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4.r),
              )),
            SizedBox(height: 14.h),
            // ── Faux map area ────────────────────────────────────────
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F0E9), Color(0xFFDCE7EA)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    // fake roads
                    Positioned.fill(
                      child: CustomPaint(painter: _RoadsPainter()),
                    ),
                    // nursery marker
                    const Positioned(
                      top: 40,
                      right: 50,
                      child: _MapPin(
                        color: _kGreen,
                        icon: Icons.home_work_rounded,
                        label: 'الحضانة',
                      ),
                    ),
                    // moving vehicle marker
                    Positioned(
                      bottom: 70,
                      left: 60,
                      child: _MapPin(
                        color: _kPurple,
                        icon: Icons.directions_car_rounded,
                        label: firstName,
                        pulse: true,
                      ),
                    ),
                  ],
                )),
            ),
            SizedBox(height: 14.h),
            // ── ETA bar ──────────────────────────────────────────────
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 24.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: _kPurple.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.directions_bus_rounded,
                        color: _kPurple, size: 22.sp)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName في الطريق للبيت',
                          style: context.typography.displaySmBold.copyWith(color: _kInk, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'باقي ٧ دقايق تقريباً · ٢.٣ كم',
                          style: context.typography.xsRegular.copyWith(color: _kMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _kPurple,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '٧ د',
                      style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.icon,
    required this.label,
    this.pulse = false,
  });
  final Color color;
  final IconData icon;
  final String label;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (pulse) _PulsingHalo(color: color),
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10.r,
                    offset: Offset(0.w, 3.h)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4.r),
            ],
          ),
          child: Text(
            label,
            style: context.typography.displaySmBold.copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          )),
      ],
    );
  }
}

class _PulsingHalo extends StatefulWidget {
  const _PulsingHalo({required this.color});
  final Color color;
  @override
  State<_PulsingHalo> createState() => _PulsingHaloState();
}

class _PulsingHaloState extends State<_PulsingHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 42 + _c.value * 40,
        height: 42 + _c.value * 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: (1 - _c.value) * 0.25),
        )),
    );
  }
}

class _RoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.85, size.height * 0.15)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.82);
    canvas.drawPath(path, p);
    // a couple of cross streets
    final p2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 5;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.3),
        Offset(size.width * 0.9, size.height * 0.35), p2);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.05),
        Offset(size.width * 0.35, size.height * 0.95), p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Next event banner (anticipatory "Fun Day" etc.) ─────────────────────────
// Shows the nearest upcoming nursery event. Data comes from
// controller.nextEvent (EventService.watchUpcomingEvents). Tapping opens the
// full events list; the primary button toggles attendance for the child.
class _NextEventCard extends StatelessWidget {
  const _NextEventCard({required this.controller});

  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.nextEvent.value;
      if (event == null) return const SizedBox.shrink();
      final color = event.category.color;

      return Padding(
        padding: EdgeInsets.only(bottom: 18.h),
        child: StaggerItem(
          index: 3,
          child: GestureDetector(
            onTap: () => Get.toNamed(parentEventsView),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: _kColoredShadow(color),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.85),
                        Color.lerp(color, Colors.white, 0.30)!,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    image: event.coverImage != null
                        ? DecorationImage(
                            image: appCachedImageProvider(event.coverImage!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              color.withValues(alpha: 0.55),
                              BlendMode.multiply,
                            ),
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        left: -20,
                        child: Container(
                          width: 110.w,
                          height: 110.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52.w,
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Icon(event.category.icon,
                                    color: Colors.white, size: 26.sp),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'parent_next_event_label'.tr,
                                      style: context.typography.xsMedium
                                          .copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        fontSize: 11,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.typography.lgBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 19,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              _EventDateChip(dateStr: event.formattedDate),
                              const Spacer(),
                              Obx(() {
                                final attending =
                                    controller.isAttendingNextEvent.value;
                                return _EventActionButton(
                                  label: attending
                                      ? 'event_attending'.tr
                                      : 'event_confirm_attendance'.tr,
                                  onTap:
                                      controller.toggleNextEventAttendance,
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _EventDateChip extends StatelessWidget {
  const _EventDateChip({required this.dateStr});

  final String dateStr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 12.sp, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            dateStr,
            style: context.typography.smSemiBold
                .copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EventActionButton extends StatelessWidget {
  const _EventActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: context.typography.displaySmBold
              .copyWith(color: const Color(0xFF1E293B), fontSize: 12),
        ),
      ),
    );
  }
}
