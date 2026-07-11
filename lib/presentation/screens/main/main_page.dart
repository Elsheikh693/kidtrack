import '../../../index/index_main.dart';

// ── Tab header configuration ──────────────────────────────────────────────────

class _TabConfig {
  const _TabConfig({
    required this.titleKey,
    required this.icon,
    required this.color,
    this.subtitleBuilder,
  });

  final String titleKey;
  final IconData icon;
  final Color color;
  final String? Function()? subtitleBuilder;
}

String? _displayName() => SessionService().currentUser?.displayName;

final _ownerConfigs = <_TabConfig>[
  _TabConfig(
    titleKey: 'owner_tab_dashboard',
    icon: Icons.insights_rounded,
    color: const Color(0xFF4F46E5),
    subtitleBuilder: _displayName,
  ),
  _TabConfig(
    titleKey: 'owner_tab_finance',
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFFD97706),
  ),
  _TabConfig(
    titleKey: 'owner_tab_communication',
    icon: Icons.dynamic_feed_rounded,
    color: const Color(0xFFEC4899),
  ),
  _TabConfig(
    titleKey: 'owner_tab_more',
    icon: Icons.grid_view_rounded,
    color: const Color(0xFF7C3AED),
    subtitleBuilder: _displayName,
  ),
];

final _teacherConfigs = <_TabConfig>[
  _TabConfig(
    titleKey: 'teacher_home_title',
    icon: Icons.school_rounded,
    color: const Color(0xFF16A34A),
    subtitleBuilder: _displayName,
  ),
  _TabConfig(
    titleKey: 'teacher_tab_activities',
    icon: Icons.play_circle_rounded,
    color: const Color(0xFF059669),
  ),
  _TabConfig(
    titleKey: 'teacher_tab_lessons',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFFD97706),
  ),
  _TabConfig(
    titleKey: 'teacher_students_title',
    icon: Icons.groups_rounded,
    color: const Color(0xFF0891B2),
  ),
];

_TabConfig? _configFor(MainPageViewModel c) {
  final List<_TabConfig>? configs = switch (c.role) {
    UserType.owner || UserType.branchManager => _ownerConfigs,
    UserType.teacher => _teacherConfigs,
    _ => null,
  };
  if (configs == null) return null;
  final idx = c.currentIndex.value;
  return idx < configs.length ? configs[idx] : null;
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MainPageViewModel controller;

  // Tabs visited at least once. We keep an IndexedStack so a tab's state
  // (scroll position, controller streams, loaded photos…) survives switching
  // away and back — but build each tab lazily on first visit so we don't open
  // every tab's Firebase streams up front.
  final _visited = <int>{};

  @override
  void initState() {
    super.initState();
    // Registered as permanent — NOT a fenix lazyPut. When the owner switches
    // into (or out of) manager view, the shell is rebuilt via
    // `Get.delete<MainPageViewModel>(force:true)` + `Get.offAllNamed(mainView)`.
    // A fenix instance created here gets disposed by the outgoing MainPage
    // route's SmartManagement.full teardown right after we grab it, leaving
    // this State bound to a dead controller whose Rx no longer notifies — so
    // every tab tap (nav bar, quick links, deep links) silently no-ops. A
    // permanent instance survives the route teardown; the explicit force-delete
    // on login / role-switch still resets it.
    controller = Get.isRegistered<MainPageViewModel>()
        ? Get.find<MainPageViewModel>()
        : Get.put(
            MainPageViewModel(initialIndex: widget.initialIndex),
            permanent: true,
          );
    _visited.add(controller.currentIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        // Hold a blank surface under the native splash until the access gate
        // resolves the restored session.
        if (!controller.gateReady.value) {
          return Scaffold(
            backgroundColor: AppColors.backgroundNeutral100,
            body: const SizedBox.shrink(),
          );
        }
        final pages = controller.pages;
        // A stale index can outlive its page list: the shell controller is
        // permanent, so switching into a role with fewer tabs (e.g. SuperAdmin
        // has a single page) leaves currentIndex pointing past the new list and
        // overflows the IndexedStack. Clamp — and heal the controller — so the
        // nav bar and stack stay in sync.
        var current = controller.currentIndex.value;
        if (current < 0 || current >= pages.length) {
          current = 0;
          if (controller.currentIndex.value != current) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => controller.currentIndex.value = current,
            );
          }
        }
        _visited.add(current);
        return Scaffold(
          backgroundColor: AppColors.backgroundNeutral100,
          body: Column(
            children: [
              _DynamicHeader(controller: controller),
              Expanded(
                child: IndexedStack(
                  index: current,
                  children: [
                    for (var i = 0; i < pages.length; i++)
                      _visited.contains(i)
                          ? pages[i]
                          : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _navBarFor(controller),
        );
      }),
    );
  }
}

// ── Dynamic header (single source of truth) ───────────────────────────────────

class _DynamicHeader extends StatelessWidget {
  const _DynamicHeader({required this.controller});

  final MainPageViewModel controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isParent) {
      // Every parent tab owns its own collapsing header inside the page
      return const SizedBox.shrink();
    }
    // Each tab embeds its own KidTrackCollapsingHeader sliver — no fixed shell header needed
    if (controller.isReceptionist ||
        controller.role == UserType.teacher ||
        controller.role == UserType.owner ||
        controller.role == UserType.branchManager) {
      return const SizedBox.shrink();
    }

    final cfg = _configFor(controller);
    if (cfg == null) return const SizedBox.shrink();

    return KidTrackHeader(
      titleKey: cfg.titleKey,
      icon: cfg.icon,
      accentColor: cfg.color,
      subtitle: cfg.subtitleBuilder?.call(),
    );
  }
}

// ── Nav bar selector ──────────────────────────────────────────────────────────

Widget? _navBarFor(MainPageViewModel c) {
  final List<_NavItemData>? items = c.isBranchManager
      ? _managerItems
      : c.isOwner
      ? _ownerItems
      : c.role == UserType.teacher
      ? _teacherItems
      : c.isParent
      ? _parentItems
      : c.isReceptionist
      ? _receptionistItems
      : c.isBusChaperone
      ? _chaperoneItems
      : null;
  if (items == null) return null;
  return _KidNavBar(
    items: items,
    currentIndex: c.currentIndex.value,
    onTap: c.changePage,
  );
}

// ── Nav item model ────────────────────────────────────────────────────────────

class _NavItemData {
  const _NavItemData({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.labelKey,
    required this.color,
    this.pageIndex,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String labelKey;
  final Color color;

  /// The IndexedStack page this nav item maps to. When null, the item's
  /// visible position is used as the page index (the common case). Use this
  /// when the bar shows fewer items than there are pages — e.g. the manager
  /// bar hides chat/finance/social (reachable from the home) but those pages
  /// still live in the stack, so "more" needs an explicit page index.
  final int? pageIndex;
}

const _teacherItems = [
  _NavItemData(
    activeIcon: Icons.home_rounded,
    inactiveIcon: Icons.home_outlined,
    labelKey: 'teacher_tab_home',
    color: Color(0xFF7C3AED),
  ),
  _NavItemData(
    activeIcon: Icons.play_circle_rounded,
    inactiveIcon: Icons.play_circle_outline_rounded,
    labelKey: 'teacher_tab_activities',
    color: Color(0xFF7C3AED),
  ),
  _NavItemData(
    activeIcon: Icons.import_contacts_rounded,
    inactiveIcon: Icons.import_contacts_outlined,
    labelKey: 'teacher_tab_link_book',
    color: Color(0xFF7C3AED),
  ),
  // مخفي مؤقتاً: تاب الواجبات
  // _NavItemData(
  //   activeIcon: Icons.assignment_rounded,
  //   inactiveIcon: Icons.assignment_outlined,
  //   labelKey: 'teacher_tab_homework',
  //   color: Color(0xFF2563EB),
  // ),
];

const _ownerItems = [
  _NavItemData(
    activeIcon: Icons.insights_rounded,
    inactiveIcon: Icons.insights_outlined,
    labelKey: 'owner_tab_dashboard',
    color: Color(0xFF4F46E5),
  ),
  _NavItemData(
    activeIcon: Icons.account_balance_wallet_rounded,
    inactiveIcon: Icons.account_balance_wallet_outlined,
    labelKey: 'owner_tab_finance',
    color: Color(0xFFD97706),
  ),
  _NavItemData(
    activeIcon: Icons.dynamic_feed_rounded,
    inactiveIcon: Icons.dynamic_feed_outlined,
    labelKey: 'owner_tab_communication',
    color: Color(0xFFEC4899),
  ),
  _NavItemData(
    activeIcon: Icons.grid_view_rounded,
    inactiveIcon: Icons.grid_view_outlined,
    labelKey: 'owner_tab_more',
    color: Color(0xFF7C3AED),
  ),
];

// Chat/finance/social were pulled out of the bar (it was too crowded) — they
// live as quick-links on the home instead. Their pages stay in the stack
// (indices 3/4/5) and remain reachable via openTab, so the visible items here
// carry explicit pageIndex values to skip over them.
const _managerItems = [
  _NavItemData(
    activeIcon: Icons.dashboard_rounded,
    inactiveIcon: Icons.dashboard_outlined,
    labelKey: 'manager_tab_dashboard',
    color: Color(0xFF4F46E5),
    pageIndex: 0,
  ),
  _NavItemData(
    activeIcon: Icons.child_care_rounded,
    inactiveIcon: Icons.child_care_outlined,
    labelKey: 'manager_tab_children',
    color: Color(0xFF16A34A),
    pageIndex: 1,
  ),
  _NavItemData(
    activeIcon: Icons.school_rounded,
    inactiveIcon: Icons.school_outlined,
    labelKey: 'manager_tab_teachers',
    color: Color(0xFF0891B2),
    pageIndex: 2,
  ),
  _NavItemData(
    activeIcon: Icons.grid_view_rounded,
    inactiveIcon: Icons.grid_view_outlined,
    labelKey: 'manager_tab_more',
    color: Color(0xFF7C3AED),
    pageIndex: 6,
  ),
];

const _parentItems = [
  _NavItemData(
    activeIcon: Icons.home_rounded,
    inactiveIcon: Icons.home_outlined,
    labelKey: 'parent_tab_dashboard',
    color: Color(0xFF5E35B1),
  ),
  _NavItemData(
    activeIcon: Icons.menu_book_rounded,
    inactiveIcon: Icons.menu_book_outlined,
    labelKey: 'parent_tab_education',
    color: Color(0xFFD97706),
  ),
  _NavItemData(
    activeIcon: Icons.dynamic_feed_rounded,
    inactiveIcon: Icons.dynamic_feed_outlined,
    labelKey: 'parent_tab_posts',
    color: Color(0xFFEC4899),
  ),
  _NavItemData(
    activeIcon: Icons.local_library_rounded,
    inactiveIcon: Icons.local_library_outlined,
    labelKey: 'parent_tab_courses',
    color: Color(0xFF0891B2),
  ),
  _NavItemData(
    activeIcon: Icons.insert_chart_rounded,
    inactiveIcon: Icons.insert_chart_outlined_rounded,
    labelKey: 'parent_tab_reports',
    color: Color(0xFF16A34A),
  ),
];

// Check-in and finance stay out of the bar — they're quick-action cards on the
// home (check-in opens via route, finance via changePage(5)). Their pages stay
// in the IndexedStack (indices 1/5) and remain reachable, so the visible items
// here carry explicit pageIndex values to skip over them. The children list is
// surfaced as its own tab (page index 2) so reception can browse a child and
// open the profile (e.g. to withdraw them).
const _receptionistItems = [
  _NavItemData(
    activeIcon: Icons.home_rounded,
    inactiveIcon: Icons.home_outlined,
    labelKey: 'reception_tab_dashboard',
    color: Color(0xFF0891B2),
    pageIndex: 0,
  ),
  _NavItemData(
    activeIcon: Icons.child_care_rounded,
    inactiveIcon: Icons.child_care_outlined,
    labelKey: 'reception_tab_children',
    color: Color(0xFF16A34A),
    pageIndex: 2,
  ),
  _NavItemData(
    activeIcon: Icons.school_rounded,
    inactiveIcon: Icons.school_outlined,
    labelKey: 'reception_tab_courses',
    color: Color(0xFF7C3AED),
    pageIndex: 3,
  ),
  _NavItemData(
    activeIcon: Icons.celebration_rounded,
    inactiveIcon: Icons.celebration_outlined,
    labelKey: 'reception_tab_events',
    color: Color(0xFFF59E0B),
    pageIndex: 4,
  ),
];

const _chaperoneItems = [
  _NavItemData(
    activeIcon: Icons.directions_bus_rounded,
    inactiveIcon: Icons.directions_bus_outlined,
    labelKey: 'tracking_tab_trip',
    color: Color(0xFF2563EB),
  ),
  _NavItemData(
    activeIcon: Icons.history_rounded,
    inactiveIcon: Icons.history_outlined,
    labelKey: 'tracking_tab_history',
    color: Color(0xFFD97706),
  ),
  _NavItemData(
    activeIcon: Icons.manage_accounts_rounded,
    inactiveIcon: Icons.manage_accounts_outlined,
    labelKey: 'tracking_tab_account',
    color: Color(0xFF6B7280),
  ),
];

// ── Floating animated nav bar ─────────────────────────────────────────────────

class _KidNavBar extends StatefulWidget {
  const _KidNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_KidNavBar> createState() => _KidNavBarState();
}

class _KidNavBarState extends State<_KidNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pillCtrl;
  late Animation<double> _pillAnim;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _pillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pillAnim = CurvedAnimation(
      parent: _pillCtrl,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(_KidNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _pillCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _pillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Container(
          height: 68.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.14),
                blurRadius: 32.r,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final itemW = constraints.maxWidth / count;

              // Map the selected page back to a visible slot. -1 means the
              // active page isn't represented in the bar (e.g. chat/finance/
              // social reached from the home) — we hide the pill in that case.
              final toPos = _posForPage(widget.currentIndex);
              final prevPos = _posForPage(_prevIndex);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // — animated pill indicator —
                  if (toPos != -1)
                    AnimatedBuilder(
                      animation: _pillAnim,
                      builder: (_, child) {
                        final fromPos = prevPos == -1 ? toPos : prevPos;
                        final fromX = _pillXFor(fromPos, itemW, count);
                        final toX = _pillXFor(toPos, itemW, count);
                        final t = _pillAnim.value;
                        final x = fromX + (toX - fromX) * t;
                        final color = widget.items[toPos].color;

                        return Positioned(
                          left: x,
                          child: Container(
                            width: itemW - 16.w,
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                        );
                      },
                    ),

                  // — tab items —
                  Row(
                    children: List.generate(count, (i) {
                      final item = widget.items[i];
                      final page = item.pageIndex ?? i;
                      final selected = widget.currentIndex == page;
                      return _KidNavItem(
                        item: item,
                        isSelected: selected,
                        onTap: () => widget.onTap(page),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _pillXFor(int pos, double itemW, int count) {
    // RTL: visible position 0 is rightmost
    final rtlIndex = (count - 1) - pos;
    return rtlIndex * itemW + 8.w;
  }

  /// Visible slot showing [pageIndex], or -1 if no item maps to it.
  int _posForPage(int pageIndex) {
    for (var i = 0; i < widget.items.length; i++) {
      if ((widget.items[i].pageIndex ?? i) == pageIndex) return i;
    }
    return -1;
  }
}

class _KidNavItem extends StatelessWidget {
  const _KidNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  color: isSelected ? item.color : AppColors.grayMedium,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 3.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: context.typography.xsRegular.copyWith(
                  color: isSelected ? item.color : AppColors.grayMedium,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  height: 1.1,
                ),
                child: Text(item.labelKey.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
