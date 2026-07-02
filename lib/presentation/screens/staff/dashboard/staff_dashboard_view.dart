import '../../../../index/index_main.dart';
import '../../../../Global/widgets/kidtrack_tab_header.dart';

// ── Module definition ────────────────────────────────────────────────────────

class _Module {
  final String permKey;
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _Module({
    required this.permKey,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const _modules = <_Module>[
  _Module(
    permKey: PermissionKeys.childrenView,
    label:   'الأطفال',
    icon:    Icons.child_care_rounded,
    color:   Color(0xFF10B981),
    route:   childrenView,
  ),
  _Module(
    permKey: PermissionKeys.attendanceView,
    label:   'الحضور',
    icon:    Icons.how_to_reg_rounded,
    color:   Color(0xFF06B6D4),
    route:   checkInView,
  ),
  _Module(
    permKey: PermissionKeys.attendanceCheckIn,
    label:   'تسجيل دخول',
    icon:    Icons.login_rounded,
    color:   Color(0xFF0EA5E9),
    route:   checkInView,
  ),
  _Module(
    permKey: PermissionKeys.classroomView,
    label:   'الفصول',
    icon:    Icons.school_rounded,
    color:   Color(0xFF8B5CF6),
    route:   classroomsView,
  ),
  _Module(
    permKey: PermissionKeys.dailyCareView,
    label:   'الرعاية اليومية',
    icon:    Icons.baby_changing_station_rounded,
    color:   Color(0xFFF59E0B),
    route:   attendanceDailyView,
  ),
  _Module(
    permKey: PermissionKeys.staffView,
    label:   'الموظفون',
    icon:    Icons.badge_rounded,
    color:   Color(0xFF6366F1),
    route:   staffView,
  ),
  _Module(
    permKey: PermissionKeys.waitingListView,
    label:   'قائمة الانتظار',
    icon:    Icons.queue_rounded,
    color:   Color(0xFF64748B),
    route:   waitingListView,
  ),
  _Module(
    permKey: PermissionKeys.pickupView,
    label:   'التسليم',
    icon:    Icons.directions_car_rounded,
    color:   Color(0xFF0891B2),
    route:   authorizedPickupView,
  ),
  _Module(
    permKey: PermissionKeys.financeView,
    label:   'المالية',
    icon:    Icons.account_balance_wallet_rounded,
    color:   Color(0xFFD97706),
    route:   invoicesView,
  ),
  _Module(
    permKey: PermissionKeys.parentsView,
    label:   'أولياء الأمور',
    icon:    Icons.family_restroom_rounded,
    color:   Color(0xFF059669),
    route:   guardianListView,
  ),
];

const _accountModule = _Module(
  permKey: '',
  label: 'حسابي',
  icon: Icons.manage_accounts_rounded,
  color: Color(0xFF7C3AED),
  route: staffAccountView,
);

// ── View ─────────────────────────────────────────────────────────────────────

class StaffDashboardView extends StatefulWidget {
  const StaffDashboardView({super.key});

  @override
  State<StaffDashboardView> createState() => _StaffDashboardViewState();
}

class _StaffDashboardViewState extends State<StaffDashboardView> {
  late final StaffDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => StaffDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            KidTrackTabHeader(
              titleKey: 'staff_title',
              icon: Icons.badge_rounded,
              accentColor: AppColors.primary,
              subtitle: controller.staffName,
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
              sliver: Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final allowed = [
                  ..._modules.where((m) => controller.has(m.permKey)),
                  _accountModule,
                ];

                if (allowed.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              size: 52.sp, color: AppColors.grayMedium),
                          SizedBox(height: 12.h),
                          Text(
                            'لا توجد صلاحيات مخصصة لك',
                            style: context.typography.smRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ModuleTile(module: allowed[i]),
                    childCount: allowed.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.9,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Module tile ───────────────────────────────────────────────────────────────

class _ModuleTile extends StatelessWidget {
  final _Module module;

  const _ModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(module.route),
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            color: module.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: module.color.withValues(alpha: 0.20),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      module.color,
                      module.color.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: module.color.withValues(alpha: 0.30),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(module.icon, size: 23.sp, color: Colors.white),
              ),
              SizedBox(height: 9.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text(
                  module.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.displaySmBold.copyWith(
                    color: module.color.darken(0.15),
                    fontSize: 10.5,
                    height: 1.3,
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
