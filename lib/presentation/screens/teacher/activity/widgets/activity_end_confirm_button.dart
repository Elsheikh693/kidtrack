import '../../../../../index/index_main.dart';

class ActivityEndConfirmButton extends StatelessWidget {
  const ActivityEndConfirmButton({
    super.key,
    required this.onTap,
    required this.mainCtrl,
  });
  final Future<void> Function() onTap;
  final TeacherActivityController mainCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activityRed,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: mainCtrl.isSaving.value ? null : onTap,
            icon: mainCtrl.isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: Text(
              'teacher_end_confirm'.tr,
              style: context.typography.smSemiBold,
            ),
          ),
        ));
  }
}
