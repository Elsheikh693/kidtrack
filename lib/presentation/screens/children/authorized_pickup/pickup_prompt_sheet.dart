import '../../../../index/index_main.dart';

/// Opens the (dismissible) first-open prompt that nudges a parent to register
/// who is allowed to pick their child up. [childId]/[childName] scope the
/// "add now" action to the currently active child.
Future<void> showPickupPromptSheet({
  required String childId,
  required String childName,
}) {
  return Get.bottomSheet(
    PickupPromptSheet(childId: childId, childName: childName),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}

/// First-open gate for the authorized-pickup nudge. Shows the sheet once per
/// device — after the mandatory child-profile sheet and the notification-prefs
/// prompt — for a parent who has never been prompted before. Optional: skipping
/// still marks it seen so it never re-appears.
class AuthorizedPickupPrompt {
  static bool _showing = false;

  static Future<void> maybeShow() async {
    if (_showing) return;
    if (!SessionService().isParent) return;

    final uid = SessionService().userId ?? '';
    if (uid.isEmpty || PickupPromptSeen.isSeen(uid)) return;

    // Come strictly after the mandatory child-profile sheet so the sheets never
    // stack on top of each other.
    if (!await ChildProfileCompletionPrompt.isActiveChildComplete()) return;

    final active = Get.find<ActiveChildService>();
    final childId = active.childId.value;
    if (childId.isEmpty) return;

    // Mark seen up-front: the nudge is optional and must show at most once.
    await PickupPromptSeen.markSeen(uid);

    if (_showing) return;
    _showing = true;
    await showPickupPromptSheet(
      childId: childId,
      childName: active.childName.value,
    );
    _showing = false;
  }
}

class PickupPromptSheet extends StatelessWidget {
  final String childId;
  final String childName;
  const PickupPromptSheet({super.key, required this.childId, required this.childName});

  void _addNow() {
    Get.back();
    Get.bottomSheet(
      PickupSheet(initialChildId: childId),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: 64.w,
                height: 64.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.how_to_reg_rounded,
                    color: const Color(0xFFF59E0B), size: 32.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'pickup_prompt_title'.tr,
                textAlign: TextAlign.center,
                style: context.typography.mdBold
                    .copyWith(fontSize: 18, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 8.h),
              Text(
                'pickup_prompt_subtitle'.tr,
                textAlign: TextAlign.center,
                style: context.typography.smRegular
                    .copyWith(color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _addNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'pickup_prompt_add'.tr,
                    style: context.typography.smSemiBold.copyWith(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: Get.back,
                child: Text(
                  'pickup_prompt_later'.tr,
                  style: context.typography.smMedium
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
