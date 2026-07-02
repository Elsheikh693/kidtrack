import '../../index/index_main.dart';

/// Fixed (non-sliver) parent header — used in MainPage shell for non-dashboard tabs.
class ParentHeader extends StatelessWidget {
  const ParentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ActiveChildService>();
    return Obx(() {
      final name = svc.childName.value;
      final status = svc.childStatus.value;
      return ClipPath(
        clipper: _ParentWaveClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary80,
                AppColors.primary,
                AppColors.primary60,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 44),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SwitchableName(
                          name: name,
                          chevronColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _StatusChip(status: status),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _WhatsAppCircleAction(),
                  const SizedBox(width: 8),
                  _CircleAction(
                    icon: Icons.notifications_outlined,
                    onTap: () => Get.toNamed(notificationsView),
                  ),
                  const SizedBox(width: 8),
                  _CircleAction(
                    icon: Icons.settings_outlined,
                    onTap: () => Get.to(() => const ParentAccountView()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Collapsing header for dashboard tab ───────────────────────────────────────

/// Collapsing SliverPersistentHeader — placed as the first sliver in
/// ParentDashboardView. Expanded shows a large purple header; on scroll it
/// collapses to a compact pinned bar.
class ParentCollapsingHeader extends StatelessWidget {
  const ParentCollapsingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ParentCollapsingDelegate(topPadding: topPadding),
    );
  }
}

class _ParentCollapsingDelegate extends SliverPersistentHeaderDelegate {
  const _ParentCollapsingDelegate({required this.topPadding});

  final double topPadding;

  static const double _expandedBody = 164.0; // content area when expanded
  static const double _wavePad = 36.0;       // extra space eaten by wave clip
  static const double _collapsedBody = 58.0; // compact bar content height

  @override
  double get minExtent => topPadding + _collapsedBody;

  @override
  double get maxExtent => topPadding + _expandedBody + _wavePad;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Obx(() {
      final svc = Get.find<ActiveChildService>();
      final name = svc.childName.value;
      final status = svc.childStatus.value;

      return SizedBox.expand(
        child: ClipPath(
          clipper: _CollapsingWaveClipper(t: t),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary80,
                  AppColors.primary,
                  AppColors.primary60,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // ── Expanded content: fades out + slides up ────────────────
                // Fixed height (not `bottom: _wavePad`) so the Column constraint
                // stays constant as the delegate shrinks during scroll —
                // prevents overflow at intermediate scroll offsets.
                Positioned(
                  top: topPadding + 8,
                  left: 20,
                  right: 20,
                  height: _expandedBody - 8,
                  child: Transform.translate(
                    offset: Offset(0, -28 * _curve(t)),
                    child: Transform.scale(
                      scale: 1.0 - 0.06 * _curve(t),
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: (1.0 - t * 2.2).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: t > 0.3,
                          child: _ExpandedContent(
                            name: name,
                            status: status,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Collapsed row: slides down from above + fades in ───────
                Positioned(
                  top: topPadding,
                  left: 16,
                  right: 16,
                  height: _collapsedBody,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      -22 * (1.0 - ((t - 0.45) * 2.0).clamp(0.0, 1.0)),
                    ),
                    child: Opacity(
                      opacity: ((t - 0.5) * 2.2).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: t < 0.7,
                        child: _CollapsedRow(name: name, status: status),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Ease-in curve so the transition accelerates at the start of the collapse.
  static double _curve(double t) => t * t;

  @override
  bool shouldRebuild(_ParentCollapsingDelegate old) =>
      old.topPadding != topPadding;
}

// ── Expanded layout ───────────────────────────────────────────────────────────

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            const _WhatsAppCircleAction(),
            const SizedBox(width: 8),
            _CircleAction(
              icon: Icons.notifications_outlined,
              onTap: () => Get.toNamed(notificationsView),
            ),
            const SizedBox(width: 8),
            _CircleAction(
              icon: Icons.settings_outlined,
              onTap: () => Get.to(() => const ParentAccountView()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SwitchableName(
          name: name,
          chevronColor: Colors.white,
          chevronSize: 26,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        _StatusChip(status: status),
      ],
    );
  }
}

// ── Collapsed row ─────────────────────────────────────────────────────────────

class _CollapsedRow extends StatelessWidget {
  const _CollapsedRow({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SwitchableName(
                name: name,
                chevronColor: Colors.white,
                chevronSize: 16,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              _StatusChip(status: status),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const _WhatsAppCircleAction(),
        const SizedBox(width: 8),
        _CircleAction(
          icon: Icons.notifications_outlined,
          onTap: () => Get.toNamed(notificationsView),
        ),
        const SizedBox(width: 8),
        _CircleAction(
          icon: Icons.settings_outlined,
          onTap: () => Get.to(() => const ParentAccountView()),
        ),
      ],
    );
  }
}

// ── Sliver version — kept for push screens like ParentMedicalView ─────────────
class ParentSliverAppBar extends StatelessWidget {
  const ParentSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ActiveChildService>();
    return Obx(() {
      final name = svc.childName.value;
      final status = svc.childStatus.value;
      return SliverToBoxAdapter(
        child: ClipPath(
          clipper: _ParentWaveClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary80,
                  AppColors.primary,
                  AppColors.primary60,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 44),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SwitchableName(
                            name: name,
                            chevronColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _StatusChip(status: status),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CircleAction(
                      icon: Icons.notifications_outlined,
                      onTap: () => Get.toNamed(notificationsView),
                    ),
                    const SizedBox(width: 8),
                    _CircleAction(
                      icon: Icons.settings_outlined,
                      onTap: () => Get.to(() => const ParentAccountView()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── New compact top bar (matches the redesigned parent home) ─────────────────

/// Light-themed compact app bar used across the parent tabs (posts, education,
/// courses) so they match the redesigned home. Self-contained: reads the active
/// child identity from [ActiveChildService]. Shows avatar + greeting + child
/// name on the right and notification / settings actions on the left.
class ParentTopBar extends StatelessWidget {
  const ParentTopBar({super.key});

  static const _kInk = Color(0xFF0F172A);
  static const _kMuted = Color(0xFF64748B);
  static const _kRed = Color(0xFFDC2626);

  static String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'صباح الخير' : 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ActiveChildService>();
    return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _kMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => _SwitchableName(
                    name: svc.childName.value,
                    chevronColor: _kInk,
                    chevronSize: 20,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ParentTopIcon(
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF25D366),
            onTap: openNurseryWhatsApp,
          ),
          const SizedBox(width: 10),
          _ParentTopIcon(
            icon: Icons.notifications_none_rounded,
            badge: true,
            onTap: () => Get.toNamed(notificationsView),
          ),
          const SizedBox(width: 10),
          _ParentTopIcon(
            icon: Icons.settings_outlined,
            onTap: () => Get.to(() => const ParentAccountView()),
          ),
        ],
      );
  }
}

class _ParentTopIcon extends StatelessWidget {
  const _ParentTopIcon({
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21, color: iconColor ?? ParentTopBar._kInk),
            if (badge)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ParentTopBar._kRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Switchable child name ─────────────────────────────────────────────────────

/// Renders the active child's name. When the parent has more than one child a
/// small chevron is shown and tapping opens the child switcher sheet.
class _SwitchableName extends StatelessWidget {
  const _SwitchableName({
    required this.name,
    required this.style,
    required this.chevronColor,
    this.chevronSize = 18,
  });

  final String name;
  final TextStyle style;
  final Color chevronColor;
  final double chevronSize;

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ActiveChildService>();
    return Obx(() {
      final hasMultiple = svc.children.length > 1;
      final label = Flexible(
        child: Text(
          name.isNotEmpty ? name : '...',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (!hasMultiple) {
        return Row(mainAxisSize: MainAxisSize.min, children: [label]);
      }
      return GestureDetector(
        onTap: () => showChildSwitcher(context),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: chevronColor, size: chevronSize),
          ],
        ),
      );
    });
  }
}

// ── Wave clippers ─────────────────────────────────────────────────────────────

class _ParentWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height + 4,
      size.width * 0.52,
      size.height - 14,
    );
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height - 30,
      size.width,
      size.height - 8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ParentWaveClipper _) => false;
}

/// Wave that flattens as `t` goes from 0 (expanded) → 1 (collapsed).
class _CollapsingWaveClipper extends CustomClipper<Path> {
  const _CollapsingWaveClipper({required this.t});

  final double t;

  @override
  Path getClip(Size size) {
    final amp = 26.0 * (1.0 - t);
    final path = Path();
    path.lineTo(0, size.height - amp);
    path.quadraticBezierTo(
      size.width * 0.28, size.height + amp * 0.15,
      size.width * 0.52, size.height - amp * 0.54,
    );
    path.quadraticBezierTo(
      size.width * 0.76, size.height - amp * 1.15,
      size.width, size.height - amp * 0.31,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CollapsingWaveClipper old) => old.t != t;
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  (String, Color, IconData) get _info => switch (status) {
    'checked_in' || 'having_meal' || 'sleeping' || 'pickup_requested' => (
      'داخل الحضانة',
      const Color(0xFF34D399),
      Icons.check_circle_rounded,
    ),
    'in_activity' => (
      'نشاط',
      const Color(0xFF60A5FA),
      Icons.directions_run_rounded,
    ),
    'on_bus' => (
      'في الباص',
      const Color(0xFFFBBF24),
      Icons.directions_bus_rounded,
    ),
    _ => ('خارج', const Color(0xFF94A3B8), Icons.home_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle icon action ────────────────────────────────────────────────────────

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.bgColor,
    this.iconColor,
    this.borderColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? iconColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}

/// Shared WhatsApp action for the dark gradient parent headers.
class _WhatsAppCircleAction extends StatelessWidget {
  const _WhatsAppCircleAction();

  @override
  Widget build(BuildContext context) {
    return _CircleAction(
      icon: Icons.chat_rounded,
      bgColor: const Color(0xFF25D366),
      iconColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      onTap: openNurseryWhatsApp,
    );
  }
}
