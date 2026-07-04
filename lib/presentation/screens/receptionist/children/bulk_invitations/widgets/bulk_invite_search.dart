import '../../../../../../index/index_main.dart';

class BulkInviteSearch extends StatelessWidget {
  final BulkInvitationsController controller;
  const BulkInviteSearch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 12.h),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.searchCtrl,
                onChanged: (v) => controller.searchQuery.value = v,
                style: context.typography.smRegular.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'rc_bulk_invite_search_hint'.tr,
                  hintStyle: const TextStyle(
                    color: Color(0xFFAEB6C4),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Icon(Icons.search, color: const Color(0xFFAEB6C4), size: 20.sp),
          ],
        ),
      ),
    );
  }
}
