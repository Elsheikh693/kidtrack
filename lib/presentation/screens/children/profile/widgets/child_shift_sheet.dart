import '../../../../../index/index_main.dart';
import '../../../receptionist/children/add_child/widgets/shift_selector.dart';

/// Bottom sheet where staff change which shift a child attends. Reuses the
/// same [ShiftSelector] shown when the child is first added, and saves through
/// [ChildProfileController.updateShift].
class ChildShiftSheet extends StatefulWidget {
  final ChildProfileController controller;
  final String? currentShift;

  const ChildShiftSheet({
    super.key,
    required this.controller,
    required this.currentShift,
  });

  @override
  State<ChildShiftSheet> createState() => _ChildShiftSheetState();
}

class _ChildShiftSheetState extends State<ChildShiftSheet> {
  String? _shift;
  List<ShiftModel> _shifts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _shift = widget.currentShift;
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    final list = await Get.find<ShiftParentService>().getActive();
    if (!mounted) return;
    setState(() {
      _shifts = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Center(
                child: Text(
                  'child_shift_edit_title'.tr,
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: Text(
                  'child_shift_edit_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ShiftSelector(
                  shifts: _shifts,
                  value: _shift,
                  onChanged: (v) => setState(() => _shift = v),
                ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _shift == null
                      ? null
                      : () => widget.controller.updateShift(_shift!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'child_details_save'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(
                    'common_cancel'.tr,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.grayMedium),
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

/// Opens the shift-edit sheet for a child.
Future<void> showChildShiftSheet({
  required ChildProfileController controller,
  required String? currentShift,
}) {
  return Get.bottomSheet(
    ChildShiftSheet(controller: controller, currentShift: currentShift),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
