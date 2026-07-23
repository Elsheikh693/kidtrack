import '../../../../index/index_main.dart';
import 'widgets/nursery_feedback_card.dart';
import 'widgets/nursery_roster_section.dart';

class NurseryDetailsView extends StatefulWidget {
  const NurseryDetailsView({super.key});

  @override
  State<NurseryDetailsView> createState() => _NurseryDetailsViewState();
}

class _NurseryDetailsViewState extends State<NurseryDetailsView> {
  late final NurseryDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryDetailsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'nursery_details_title'.tr,
            style: context.typography.mdBold.copyWith(
              color: const Color(0xFF1E293B),
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAddOwner,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
          label: Text(
            'nursery_add_owner_btn'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          children: [
            _infoCard(),
            SizedBox(height: 20.h),
            NurseryFeedbackCard(controller: controller),
            SizedBox(height: 20.h),
            Text(
              'nursery_owners_count'.tr,
              style: context.typography.displaySmBold.copyWith(
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 10.h),
            _ownersList(),
            SizedBox(height: 20.h),
            NurseryRosterSection(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nursery_info_section'.tr,
            style: context.typography.displaySmBold.copyWith(
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          _label('nursery_name_label'.tr),
          SizedBox(height: 6.h),
          _field(controller.nameCtrl, 'nursery_name_hint'.tr),
          SizedBox(height: 14.h),
          _label('nursery_phone_label'.tr),
          SizedBox(height: 6.h),
          _field(
            controller.phoneCtrl,
            'nursery_phone_hint'.tr,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 14.h),
          _label('nursery_address_label'.tr),
          SizedBox(height: 6.h),
          _field(controller.addressCtrl, 'nursery_address_hint'.tr),
          SizedBox(height: 20.h),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: controller.savingInfo.value
                    ? null
                    : controller.saveInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'nursery_save_info_btn'.tr,
                  style: context.typography.smSemiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownersList() {
    return Obx(() {
      if (controller.loadingOwners.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.owners.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 28.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'nursery_owners_empty'.tr,
            style: context.typography.smRegular.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        );
      }
      return Column(
        children: controller.owners
            .map(
              (owner) => OwnerTile(
                owner: owner,
                onEdit: () => controller.openEditOwner(owner),
                onDelete: () => controller.confirmDeleteOwner(owner),
                onShowCode: () => controller.showOwnerActivation(owner),
                onSendWhatsApp: () =>
                    controller.sendOwnerActivationWhatsApp(owner),
              ),
            )
            .toList(),
      );
    });
  }

  Widget _label(String text) => Text(
    text,
    style: context.typography.smMedium.copyWith(
      fontSize: 14,
      color: const Color(0xFF475569),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: ctrl,
    keyboardType: keyboardType,
    style: context.typography.smRegular.copyWith(
      color: const Color(0xFF1E293B),
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(
        color: const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
  );
}
