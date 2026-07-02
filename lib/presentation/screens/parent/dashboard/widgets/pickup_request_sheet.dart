import '../../../../../index/index_main.dart';
import '../controller.dart';

void showPickupRequestSheet(
    BuildContext context, ParentDashboardController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickupSheet(controller: controller),
  );
}

class _PickupSheet extends StatefulWidget {
  const _PickupSheet({required this.controller});
  final ParentDashboardController controller;

  @override
  State<_PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<_PickupSheet> {
  String? _selectedEta;

  static const _etaOptions = ['10 دقائق', '15 دقيقة', '20 دقيقة', '30 دقيقة'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.only(
          top: 20.h,
          right: 24.w,
          left: 24.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4.r),
                )),
            ),
            SizedBox(height: 20.h),
            // header
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.primary,
                    size: 26.sp)),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب استلام ${widget.controller.childName.split(' ').first}',
                      style: context.typography.mdBold.copyWith(color: Color(0xFF1E293B), fontSize: 16),
                    ),
                    Text(
                      'اختر وقت وصولك المتوقع',
                      style: context.typography.xsRegular.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // ETA options
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _etaOptions.map((eta) {
                final selected = _selectedEta == eta;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEta = eta),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 22.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.backgroundNeutral100,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.borderNeutralPrimary,
                        width: selected ? 0 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8.r,
                                offset: Offset(0.w, 3.h))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15.sp,
                          color:
                              selected ? Colors.white : AppColors.textSecondaryParagraph),
                        SizedBox(width: 6.w),
                        Text(
                          eta,
                          style: context.typography.smSemiBold.copyWith(color: selected
                                ? Colors.white
                                : AppColors.textDefault, fontSize: 14),
                        ),
                      ],
                    )),
                );
              }).toList(),
            ),
            SizedBox(height: 28.h),
            // info note
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: const Color(0xFF059669).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF059669), size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'سيتم إبلاغ الاستقبال بموعد وصولك لتجهيز ${widget.controller.childName.split(' ').first}',
                      style: context.typography.xsRegular.copyWith(color: Color(0xFF065F46), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              )),
            SizedBox(height: 20.h),
            // confirm button
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: _selectedEta != null ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  onPressed: _selectedEta == null
                      ? null
                      : () {
                          widget.controller.requestPickup(_selectedEta!);
                          Get.back();
                        },
                  icon: Icon(Icons.send_rounded, size: 18.sp),
                  label: Text(
                    _selectedEta != null
                        ? 'سأصل خلال $_selectedEta'
                        : 'اختر وقت الوصول أولاً',
                    style: context.typography.displaySmBold.copyWith(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary,
                    disabledForegroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: _selectedEta != null ? 4 : 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

// ── Pickup FAB ────────────────────────────────────────────────────────────────

class PickupFab extends StatelessWidget {
  const PickupFab({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final requested = controller.pickupRequested.value;
      final eta = controller.pickupEta.value;

      if (requested) {
        return FloatingActionButton.extended(
          heroTag: 'pickup_fab',
          onPressed: () => _showCancelDialog(context),
          backgroundColor: const Color(0xFF059669),
          icon: Icon(Icons.directions_car_rounded,
              color: Colors.white, size: 20.sp),
          label: Text(
            'في الطريق • $eta',
            style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 13),
          ),
        );
      }

      return FloatingActionButton.extended(
        heroTag: 'pickup_fab',
        onPressed: () =>
            showPickupRequestSheet(context, controller),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.directions_car_rounded,
            color: Colors.white, size: 20.sp),
        label: Text(
          'طلب استلام',
          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 13),
        ),
      );
    });
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('إلغاء طلب الاستلام؟',
              style: context.typography.mdBold.copyWith(fontSize: 16)),
          content: Text('هل تريد إلغاء طلب الاستلام الحالي؟',
              style: context.typography.xsRegular.copyWith(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('لا', style: context.typography.smRegular.copyWith(color: AppColors.textSecondaryParagraph)),
            ),
            TextButton(
              onPressed: () {
                controller.cancelPickup();
                Get.back();
              },
              child: Text('نعم، إلغاء',
                  style: context.typography.displaySmBold.copyWith(color: Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }
}
