import '../../../../../index/index_main.dart';
import 'showcase_roles.dart';

/// Horizontal role selector for the showcase albums screen. Each chip shows the
/// album's role label and its current shot count.
class ShowcaseRoleTabs extends StatelessWidget {
  final SaShowcaseAlbumsController controller;

  const ShowcaseRoleTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: kShowcaseRoles.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final role = kShowcaseRoles[i];
          return Obx(() {
            final selected = controller.selectedRole.value == role.key;
            final count = controller.shotCountFor(role.key);
            return GestureDetector(
              onTap: () => controller.selectRole(role.key),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? role.color : AppColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: selected ? role.color : const Color(0xFFE2E8F0),
                  ),
                ),
                child: AppText(
                  text: '${role.labelKey.tr} ($count)',
                  textStyle: context.typography.smSemiBold.copyWith(
                    color: selected ? AppColors.white : AppColors.textDefault,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
