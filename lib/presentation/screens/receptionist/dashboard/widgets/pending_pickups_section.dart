import '../../../../../index/index_main.dart';
import '../controller.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _accent = Color(0xFF0891B2);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _faint = Color(0xFFAEB6C4);
const _line = Color(0xFFEDF0F4);
const _purple = Color(0xFF7C3AED);

/// Pending pickup-requests section: a section title with a live count badge,
/// followed by the list (loading skeleton / empty card / request tiles).
///
/// Shared by the Home dashboard and the Operations tab so both stay in sync.
class PendingPickupsSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const PendingPickupsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _SectionTitle(
              'reception_pending_pickups_title'.tr,
              trailing: '${controller.pendingPickups.length}',
            )),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.isLoading.value) return const _PickupsLoading();
          final pickups = controller.pendingPickups;
          if (pickups.isEmpty) return const _PickupsEmpty();
          return Column(
            children:
                pickups.map((p) => _PickupRequestTile(data: p)).toList(),
          );
        }),
      ],
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5.w,
          height: 17.h,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 9.w),
        Text(
          title,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              trailing!,
              style: context.typography.displaySmBold.copyWith(
                color: _accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

// ── List states ────────────────────────────────────────────────────────────────

class _PickupsEmpty extends StatelessWidget {
  const _PickupsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_outlined,
              size: 30.sp, color: _faint.withValues(alpha: 0.7)),
          SizedBox(height: 8.h),
          Text(
            'reception_pickups_empty'.tr,
            style: context.typography.xsMedium.copyWith(
              fontSize: 13,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupsLoading extends StatelessWidget {
  const _PickupsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 72.h,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _line),
          ),
        ),
      ),
    );
  }
}

// ── Pending pickup request tile ────────────────────────────────────────────────

class _PickupRequestTile extends StatelessWidget {
  final PendingPickupData data;
  const _PickupRequestTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.directions_car_rounded,
                color: _purple, size: 21.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.childName,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 13.sp, color: _faint),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        data.parentName,
                        style: context.typography.xsMedium.copyWith(
                          fontSize: 12,
                          color: _muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 12.sp, color: _faint),
                  SizedBox(width: 3.w),
                  Text(
                    data.time,
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 11.5,
                      color: _muted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => Get.toNamed(pickupRequestsView),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Text(
                    'reception_pickup_verify_btn'.tr,
                    style: context.typography.displaySmBold.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
