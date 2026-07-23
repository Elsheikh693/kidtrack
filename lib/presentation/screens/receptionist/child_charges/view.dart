import '../../../../index/index_main.dart';
import 'widgets/child_charge_card.dart';
import 'widgets/child_charges_empty.dart';
import 'widgets/child_charges_shimmer.dart';

/// Reception "daily expenses" screen — lists ad-hoc charges added for children
/// and lets staff add/edit/delete them. Sits where "Learn the App" used to be
/// on the reception home.
class ChildChargesView extends StatefulWidget {
  const ChildChargesView({super.key});

  @override
  State<ChildChargesView> createState() => _ChildChargesViewState();
}

class _ChildChargesViewState extends State<ChildChargesView> {
  late final ChildChargesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChildChargesController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'daily_expense_title'.tr),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'daily_expense_add'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'daily_expense_search'.tr,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.grayMedium, size: 20.sp),
                  filled: true,
                  fillColor: AppColors.white,
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
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ChildChargesShimmer();
                }
                final items = controller.filtered;
                if (items.isEmpty) return const ChildChargesEmpty();
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ChildChargeCard(
                    controller: controller,
                    charge: items[i],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
