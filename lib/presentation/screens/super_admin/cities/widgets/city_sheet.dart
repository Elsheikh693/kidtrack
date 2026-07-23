import '../../../../../index/index_main.dart';

class CitySheet extends StatefulWidget {
  final CityModel? existing;
  const CitySheet({super.key, this.existing});

  @override
  State<CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<CitySheet> with KeyboardSheetMixin {
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.existing?.name ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('cities_name_required'.tr);
      return;
    }
    final isNew = widget.existing == null;
    final key =
        widget.existing?.key ?? 'city_${DateTime.now().millisecondsSinceEpoch}';
    final model = CityModel(
      key: key,
      name: name,
      isActive: true,
      createdAt:
          widget.existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final service = Get.find<CityParentService>();
    Loader.show();
    service.save(
      item: model,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess(isNew ? 'cities_saved'.tr : 'cities_updated'.tr);
          Get.back();
        } else {
          Loader.showError('cities_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'cities_add'.tr : 'cities_edit'.tr,
                style: context.typography.lgBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 20.h),
              Text(
                'cities_name_label'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF374151)),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'cities_name_hint'.tr,
                  hintStyle: context.typography.xsRegular
                      .copyWith(fontSize: 13, color: const Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    widget.existing == null
                        ? 'cities_save'.tr
                        : 'cities_update'.tr,
                    style: context.typography.smSemiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
