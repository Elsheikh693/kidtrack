import '../../../../../index/index_main.dart';

class ChildSearchBar extends StatelessWidget {
  final ChildListController controller;
  final FocusNode? focusNode;

  const ChildSearchBar({super.key, required this.controller, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: TextField(
        focusNode: focusNode,
        controller: controller.searchCtrl,
        onChanged: (v) => controller.searchQuery.value = v,
        style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'child_search_hint'.tr,
          hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      controller.searchCtrl.clear();
                      controller.searchQuery.value = '';
                    },
                  ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
