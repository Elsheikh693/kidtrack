import '../../../../../index/index_main.dart';

class DiscoverySearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController? textController;
  final bool autofocus;

  const DiscoverySearchBar({
    super.key,
    required this.onChanged,
    this.textController,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary80.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        autofocus: autofocus,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: context.typography.smRegular
            .copyWith(color: AppColors.textDefault),
        decoration: InputDecoration(
          hintText: 'discovery_search_hint'.tr,
          hintStyle: context.typography.smRegular
              .copyWith(color: AppColors.textFieldPlaceholder),
          prefixIcon:
              Icon(Icons.search_rounded, color: AppColors.primary60, size: 22.sp),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
        ),
      ),
    );
  }
}
