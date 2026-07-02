import '../../../../index/index_main.dart';
import '../dashboard/widgets/check_in_button.dart';
import '../dashboard/widgets/pending_pickups_section.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _accent = Color(0xFF0891B2);
const _ink = Color(0xFF111827);
const _faint = Color(0xFFAEB6C4);
const _line = Color(0xFFEDF0F4);
const _amber = Color(0xFFF59E0B);

/// Operations screen — the receptionist's detailed daily lists (pending pickup
/// requests, events). Quick actions + the live banner live on the Home tab.
///
/// NOTE: the pickup list below is mock data to lock the design.
class ReceptionistOperationsTab extends StatefulWidget {
  const ReceptionistOperationsTab({super.key});

  @override
  State<ReceptionistOperationsTab> createState() =>
      _ReceptionistOperationsTabState();
}

class _ReceptionistOperationsTabState extends State<ReceptionistOperationsTab> {
  late final ReceptionistDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReceptionistDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFBFC),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadDashboard,
                color: _accent,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
                    const OpsCheckInButton(),
                    const SizedBox(height: 22),
                    PendingPickupsSection(controller: controller),
                    const SizedBox(height: 22),
                    _SectionTitle('reception_action_events'.tr),
                    const SizedBox(height: 12),
                    _NavRow(
                      icon: Icons.celebration_rounded,
                      color: _amber,
                      label: 'reception_action_events'.tr,
                      onTap: () => Get.toNamed(receptionistEventsView),
                    ),
                    const SizedBox(height: 12),
                    _NavRow(
                      icon: Icons.event_busy_rounded,
                      color: const Color(0xFF6C4DDB),
                      label: 'الإجازات',
                      onTap: () => Get.toNamed(holidaysView),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plain top bar ──────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 18, 14),
      child: Row(
        children: [
          Text(
            'reception_tab_operations'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(notificationsView),
            child: const Icon(Icons.notifications_none_rounded,
                size: 24, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Get.toNamed(settingsView),
            child: const Icon(Icons.settings_outlined,
                size: 24, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 17,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ── Navigation row ─────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _faint),
          ],
        ),
      ),
    );
  }
}

