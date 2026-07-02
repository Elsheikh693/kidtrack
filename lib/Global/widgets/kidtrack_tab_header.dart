import '../../index/index_main.dart';

// ── Universal collapsing sliver header ────────────────────────────────────────

/// Drop this as the **first sliver** in any `CustomScrollView` to get the same
/// wave + slide/scale/fade collapse transition used by the parent dashboard.
class KidTrackCollapsingHeader extends StatelessWidget {
  const KidTrackCollapsingHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _KidTrackCollapsingDelegate(
        title: title,
        icon: icon,
        accentColor: accentColor,
        subtitle: subtitle,
        topPadding: topPadding,
      ),
    );
  }
}

class _KidTrackCollapsingDelegate extends SliverPersistentHeaderDelegate {
  const _KidTrackCollapsingDelegate({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.topPadding,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final double topPadding;
  final String? subtitle;

  // Fixed height so the Column constraint never shrinks during scroll
  static const double _expandedBody = 138.0;
  static const double _wavePad = 36.0;
  static const double _collapsedBody = 56.0;

  @override
  double get minExtent => topPadding + _collapsedBody;
  @override
  double get maxExtent => topPadding + _expandedBody + _wavePad;

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  // Ease-in: accelerates into collapse, feels natural
  static double _ease(double t) => t * t;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final dark = _darken(accentColor, 0.18);
    final mid  = _darken(accentColor, 0.06);

    return SizedBox.expand(
      child: ClipPath(
        clipper: _WaveCollapsingClipper(t: t),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [dark, mid, accentColor],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Expanded content: fades out + slides up ──────────────────
              Positioned(
                top: topPadding + 8,
                left: 20,
                right: 20,
                height: _expandedBody - 8, // fixed — no shrink-related overflow
                child: Transform.translate(
                  offset: Offset(0, -26 * _ease(t)),
                  child: Transform.scale(
                    scale: 1.0 - 0.06 * _ease(t),
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: (1.0 - t * 2.2).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: t > 0.3,
                        child: _HeaderExpanded(
                          title: title,
                          subtitle: subtitle,
                          icon: icon,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Collapsed row: slides down from above + fades in ──────────
              Positioned(
                top: topPadding,
                left: 16,
                right: 16,
                height: _collapsedBody,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -20 * (1.0 - ((t - 0.45) * 2.0).clamp(0.0, 1.0)),
                  ),
                  child: Opacity(
                    opacity: ((t - 0.5) * 2.2).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: t < 0.7,
                      child: _HeaderCollapsed(title: title, icon: icon),
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

  @override
  bool shouldRebuild(_KidTrackCollapsingDelegate old) =>
      old.title != title ||
      old.subtitle != subtitle ||
      old.accentColor != accentColor ||
      old.topPadding != topPadding;
}

// ── Expanded layout ───────────────────────────────────────────────────────────

class _HeaderExpanded extends StatelessWidget {
  const _HeaderExpanded({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            _NotificationBell(),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ── Collapsed layout ──────────────────────────────────────────────────────────

class _HeaderCollapsed extends StatelessWidget {
  const _HeaderCollapsed({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _NotificationBell(),
      ],
    );
  }
}

// ── Collapsing wave clipper ───────────────────────────────────────────────────

class _WaveCollapsingClipper extends CustomClipper<Path> {
  const _WaveCollapsingClipper({required this.t});
  final double t;

  @override
  Path getClip(Size size) {
    final amp = 28.0 * (1.0 - t);
    final path = Path();
    path.lineTo(0, size.height - amp);
    path.quadraticBezierTo(
      size.width * 0.28, size.height + amp * 0.14,
      size.width * 0.52, size.height - amp * 0.57,
    );
    path.quadraticBezierTo(
      size.width * 0.76, size.height - amp * 1.14,
      size.width,        size.height - amp * 0.30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveCollapsingClipper old) => old.t != t;
}

// ── Fixed (non-sliver) wave header — used in MainPage shell above IndexedStack.
class KidTrackHeader extends StatelessWidget {
  const KidTrackHeader({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.trailing,
    this.showNotificationBell = true,
  });

  final String titleKey;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final Widget? trailing;
  final bool showNotificationBell;

  @override
  Widget build(BuildContext context) {
    final dark = _darken(accentColor, 0.18);
    final mid  = _darken(accentColor, 0.06);

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [dark, mid, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBadge(icon: icon, color: accentColor),
                    const Spacer(),
                    if (trailing != null) trailing!,
                    if (showNotificationBell) ...[
                      if (trailing != null) const SizedBox(width: 8),
                      _NotificationBell(),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  titleKey.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Sliver version — kept for push screens that embed it in CustomScrollView.
class KidTrackTabHeader extends StatelessWidget {
  const KidTrackTabHeader({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.trailing,
    this.showNotificationBell = true,
  });

  final String titleKey;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final Widget? trailing;
  final bool showNotificationBell;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: KidTrackHeader(
          titleKey: titleKey,
          icon: icon,
          accentColor: accentColor,
          subtitle: subtitle,
          trailing: trailing,
          showNotificationBell: showNotificationBell,
        ),
      );
}

// ── Wave clipper ─────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5,  size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 32,
      size.width,        size.height - 12,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper _) => false;
}

// ── Icon badge ───────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

// ── Notification bell ────────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(notificationsView),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

