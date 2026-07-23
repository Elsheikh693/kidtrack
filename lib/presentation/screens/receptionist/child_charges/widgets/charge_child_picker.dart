import '../../../../../index/index_main.dart';

/// A searchable child picker opened from the add-charge sheet. Pops the selected
/// [ChildModel] back to the caller via `Get.back(result: child)`.
class ChargeChildPicker extends StatefulWidget {
  const ChargeChildPicker({super.key, required this.children});

  final List<ChildModel> children;

  @override
  State<ChargeChildPicker> createState() => _ChargeChildPickerState();
}

class _ChargeChildPickerState extends State<ChargeChildPicker> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? widget.children
        : widget.children
            .where((c) => c.fullName.toLowerCase().contains(q))
            .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'daily_expense_search_child'.tr,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.grayMedium, size: 20.sp),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
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
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 24.h),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final child = items[i];
                  return ListTile(
                    leading: ChildAvatar(
                      name: child.fullName,
                      imageUrl: child.profileImage,
                      size: 40,
                    ),
                    title: Text(
                      child.fullName,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    onTap: () => Get.back(result: child),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
