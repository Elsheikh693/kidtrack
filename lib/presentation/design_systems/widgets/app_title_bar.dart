import '../../../../index/index_main.dart';

/// Unified screen header used across the reception tabs (and the shared chat
/// tab): a pure-white bar with a bold screen title on the leading side and
/// optional notification + settings icons on the trailing side.
///
/// It is a plain widget (with its own top [SafeArea]) so it can sit as the
/// first child of a tab's [Column] — the reception tabs are not all wrapped in
/// a [Scaffold], so an `appBar:` slot isn't always available.
class AppTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;

  const AppTitleBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              if (onNotificationTap != null) ...[
                _IconBtn(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap!,
                ),
                const SizedBox(width: 14),
              ],
              if (onSettingsTap != null)
                _IconBtn(
                  icon: Icons.settings_outlined,
                  onTap: onSettingsTap!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 25, color: const Color(0xFF374151)),
      );
}
