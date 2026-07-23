import '../../../../../index/index_main.dart';

/// Opens a read-only sheet listing everyone authorized to pick [child] up, so
/// reception can verify who is collecting the child at check-out. Tapping an
/// ID-card thumbnail opens it full-screen.
void showPickupPersonsSheet(ChildModel child, List<AuthorizedPickupModel> persons) {
  Get.bottomSheet(
    _PickupPersonsSheet(childName: child.fullName, persons: persons),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

class _PickupPersonsSheet extends StatelessWidget {
  final String childName;
  final List<AuthorizedPickupModel> persons;
  const _PickupPersonsSheet({required this.childName, required this.persons});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'pickup_authorized_title'.tr,
                style: context.typography.mdBold
                    .copyWith(fontSize: 18, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 2.h),
              Text(
                childName,
                style: context.typography.smRegular
                    .copyWith(color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 16.h),
              if (persons.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'pickup_none_authorized'.tr,
                      style: context.typography.smRegular
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: persons.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) => _PersonRow(person: persons[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final AuthorizedPickupModel person;
  const _PersonRow({required this.person});

  @override
  Widget build(BuildContext context) {
    final hasId = person.idImage != null && person.idImage!.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: hasId ? () => showFullImage(person.idImage!) : null,
            child: Container(
              width: 52.w,
              height: 52.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: hasId
                  ? AppNetworkImage(url: person.idImage, fit: BoxFit.cover)
                  : Icon(Icons.person_outline,
                      color: const Color(0xFFF59E0B), size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: context.typography.smSemiBold
                      .copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
                ),
                SizedBox(height: 2.h),
                Text(
                  'pickup_rel_${person.relationship}'.tr,
                  style: context.typography.xsRegular
                      .copyWith(fontSize: 13, color: const Color(0xFF64748B)),
                ),
                if (person.phone != null && person.phone!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 13.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 4.w),
                      Text(
                        person.phone!,
                        style: context.typography.xsRegular.copyWith(
                            fontSize: 13, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (hasId)
            Icon(Icons.badge_outlined,
                size: 18.sp, color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}
