import '../../../index/index_main.dart';

/// Owner → "act as branch manager". Opens a branch picker; on selection the
/// session enters manager view for that branch and the app shell is rebuilt so
/// the owner sees the full Manager app. The real identity stays `owner`.
Future<void> showSwitchToBranchSheet() async {
  final session = SessionService();
  if (!session.canSwitchRole) return;
  await Get.bottomSheet(
    const _BranchPickerSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

/// Manager view → back to the owner dashboard.
Future<void> backToOwnerMode() async {
  await SessionService().exitManagerMode();
  _rebuildShell();
}

/// In-app IDENTITY switch for a multi-hat person (teacher + mum, staff at two
/// nurseries, …) — distinct from the owner "act as manager" view above, which
/// only changes the rendered shell. This actually swaps which membership the
/// session runs as. Reuses the login role picker; picking a role hands it to
/// [AuthBootstrapService.finalizeMembership], which re-scopes + rebuilds the
/// shell. No-op when the identity holds a single membership.
Future<void> openRoleSwitcher() async {
  final session = SessionService();
  final uid = session.userId;
  final user = session.currentUser;
  if (uid == null || user == null) return;

  Loader.show();
  final memberships = await Get.find<IdentityService>().memberships(uid);
  Loader.dismiss();

  if (memberships.length < 2) {
    Loader.showError('role_switch_none'.tr);
    return;
  }

  Get.toNamed(
    membershipPickerView,
    arguments: {
      'uid': uid,
      'identity': {
        'name': user.name,
        'phone': user.phone,
        'email': user.email,
      },
      'memberships': memberships.map((m) => m.toJson()).toList(),
      'canCancel': true,
    },
  );
}

void _rebuildShell() {
  Get.delete<MainPageViewModel>(force: true);
  Get.offAllNamed(mainView);
}

class _BranchPickerSheet extends StatefulWidget {
  const _BranchPickerSheet();

  @override
  State<_BranchPickerSheet> createState() => _BranchPickerSheetState();
}

class _BranchPickerSheetState extends State<_BranchPickerSheet> {
  final _service = BranchParentService();
  final _branches = <BranchModel>[].obs;
  final _loading = true.obs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.getAll(callBack: (list) {
      _branches.assignAll(
        list.whereType<BranchModel>().where((b) => b.isActive),
      );
      _loading.value = false;
    });
  }

  Future<void> _select(BranchModel branch) async {
    final id = branch.key;
    if (id == null || id.isEmpty) return;
    Get.back();
    await SessionService().enterManagerMode(id);
    _rebuildShell();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutralPrimary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'owner_switch_pick_branch'.tr,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 4.h),
            Text(
              'owner_switch_pick_branch_hint'.tr,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: Obx(() {
                if (_loading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (_branches.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text(
                        'owner_switch_no_branches'.tr,
                        style: context.typography.smRegular
                            .copyWith(color: AppColors.textSecondaryParagraph),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _branches.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _BranchTile(
                    branch: _branches[i],
                    onTap: () => _select(_branches[i]),
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

class _BranchTile extends StatelessWidget {
  const _BranchTile({required this.branch, required this.onTap});

  final BranchModel branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.account_balance_rounded,
                  color: const Color(0xFF7C3AED), size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  if ((branch.address ?? '').isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        branch.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (branch.isMain)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'owner_switch_main_branch'.tr,
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF7C3AED)),
                ),
              ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
