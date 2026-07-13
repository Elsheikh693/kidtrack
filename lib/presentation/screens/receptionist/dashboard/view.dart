import 'package:intl/intl.dart' as intl;
import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/inside_now_banner.dart';
import 'widgets/pending_pickups_section.dart';
import 'widgets/home_action_cards.dart';
import 'widgets/active_events_section.dart';
import '../../manager/media_approval/widgets/media_approval_banner.dart';

const _accent = Color(0xFF0891B2);

class ReceptionistDashboardView extends StatefulWidget {
  const ReceptionistDashboardView({super.key});

  @override
  State<ReceptionistDashboardView> createState() =>
      _ReceptionistDashboardViewState();
}

class _ReceptionistDashboardViewState extends State<ReceptionistDashboardView> {
  late final ReceptionistDashboardController controller;

  @override
  void initState() {
    super.initState();
    // When the controller already exists (returning to the Home tab after an
    // action like adding a child), onInit won't re-run — so refresh manually to
    // avoid showing stale data. On the very first mount onInit already loads.
    final alreadyLive = Get.isRegistered<ReceptionistDashboardController>();
    controller = initController(() => ReceptionistDashboardController());
    if (alreadyLive) controller.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFBFC),
      child: Column(
        children: [
          _HomeHeader(controller: controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDashboard,
              color: _accent,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        InsideNowBanner(controller: controller),
                        SizedBox(height: 16.h),
                        const HomeActionCards(),
                        SizedBox(height: 18.h),
                        const MediaApprovalBanner(),
                        const AbsentTodaySection(previewLimit: 3),
                        SizedBox(height: 22.h),
                        const UnpaidSubscriptionCard(),
                        PendingPickupsSection(controller: controller),
                        SizedBox(height: 24.h),
                        ActiveEventsSection(controller: controller),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact greeting header ────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const _HomeHeader({required this.controller});

  String get _formattedDate {
    final locale = Get.locale?.languageCode == 'ar' ? 'ar' : 'en';
    return intl.DateFormat('EEEE، d MMMM', locale).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final name = SessionService().currentUser?.displayName ?? '';
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 18.w, 14.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'reception_dashboard_greeting'.tr,
                      style: context.typography.xsRegular.copyWith(
                        color: const Color(0xFF8A93A4),
                        fontSize: 12.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      name,
                      style: context.typography.lgBold.copyWith(
                        color: const Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12.sp,
                          color: _accent,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formattedDate,
                          style: context.typography.xsMedium.copyWith(
                            color: const Color(0xFF8A93A4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _CircleIconBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    // index 6 in _receptionistPages: the shared parent chat inbox.
                    onTap: () => Get.find<MainPageViewModel>().changePage(6),
                  ),
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Obx(() {
                      final n = controller.chatUnread;
                      if (n <= 0) return const SizedBox.shrink();
                      return ChatUnreadBadge(count: n);
                    }),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              _CircleIconBtn(
                icon: Icons.notifications_none_rounded,
                onTap: () => Get.toNamed(notificationsView),
              ),
              SizedBox(width: 10.w),
              _CircleIconBtn(
                icon: Icons.settings_outlined,
                onTap: () => Get.toNamed(settingsView),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.h,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _accent, size: 21.sp),
      ),
    );
  }
}
