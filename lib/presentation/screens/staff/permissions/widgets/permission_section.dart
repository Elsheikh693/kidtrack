import '../../../../../index/index_main.dart';

class PermissionSection extends StatelessWidget {
  final List<String> keys;
  final RxMap<String, bool> permissions;
  final void Function(String) onToggle;

  const PermissionSection({
    super.key,
    required this.keys,
    required this.permissions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
          child: AppText(
            text: PermissionLabels.groupOf(keys.first),
            textStyle: context.typography.xsMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < keys.length; i++)
                Obx(() => _PermissionRow(
                      label: PermissionLabels.label(keys[i]),
                      value: permissions[keys[i]] ?? false,
                      onChanged: (_) => onToggle(keys[i]),
                      showDivider: i < keys.length - 1,
                    )),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _PermissionRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  text: label,
                  textStyle: context.typography.smMedium.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16.w,
            endIndent: 16.w,
            color: AppColors.backgroundNeutral100,
          ),
      ],
    );
  }
}
