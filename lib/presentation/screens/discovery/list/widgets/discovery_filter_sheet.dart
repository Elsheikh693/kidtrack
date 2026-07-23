import 'package:flutter/cupertino.dart';
import '../../../../../index/index_main.dart';

/// Rich pre-login discovery filter. Lets a parent narrow nurseries by their
/// child's age, a normalized monthly-price window, and (optionally) distance.
/// Location is opt-in only — permission is requested when the toggle is turned
/// on, never when the sheet opens.
void showDiscoveryFilterSheet(DiscoveryController controller) {
  Get.bottomSheet(
    _FilterSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

String _filterAgeLabel(int? months) {
  if (months == null) return 'discovery_filter_age_any'.tr;
  final y = months ~/ 12;
  final m = months % 12;
  if (y > 0 && m > 0) {
    return 'age_years_months'.trParams({'y': '$y', 'm': '$m'});
  }
  if (y > 0) return 'age_years'.trParams({'n': '$y'});
  return 'age_months'.trParams({'n': '$m'});
}

class _FilterSheet extends StatefulWidget {
  final DiscoveryController controller;
  const _FilterSheet({required this.controller});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _ageMonths;
  late RangeValues _price;
  late double? _distanceKm;
  late String? _cityId;

  double get _minBound => widget.controller.priceBoundMin;
  double get _maxBound => widget.controller.priceBoundMax;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _ageMonths = c.childAgeMonths.value;
    _price = c.priceRange.value ?? RangeValues(_minBound, _maxBound);
    _distanceKm = c.distanceKm.value ?? 10;
    _cityId = c.cityId.value;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: 'discovery_filter_title'.tr,
                      textStyle: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                  ),
                  GestureDetector(
                    onTap: _reset,
                    child: AppText(
                      text: 'discovery_filter_reset'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // ── City ───────────────────────────────────────────────────
              Obx(() {
                if (widget.controller.cities.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(context, 'discovery_filter_city'.tr,
                        Icons.location_city_rounded),
                    SizedBox(height: 10.h),
                    _CityDropdown(
                      cities: widget.controller.cities,
                      selectedId: _cityId,
                      onChanged: (id) => setState(() => _cityId = id),
                    ),
                    SizedBox(height: 22.h),
                  ],
                );
              }),

              // ── Child age ──────────────────────────────────────────────
              _label(context, 'discovery_filter_age'.tr, Icons.child_care_rounded),
              SizedBox(height: 10.h),
              _AgeSelector(
                label: _filterAgeLabel(_ageMonths),
                onTap: _pickAge,
                onClear: _ageMonths == null
                    ? null
                    : () => setState(() => _ageMonths = null),
              ),
              SizedBox(height: 22.h),

              // ── Monthly price ──────────────────────────────────────────
              _label(context, 'discovery_filter_price'.tr,
                  Icons.payments_rounded),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: _priceLabel(_price.start),
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.primary),
                  ),
                  AppText(
                    text: _priceLabel(_price.end),
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              RangeSlider(
                values: _price,
                min: _minBound,
                max: _maxBound,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.grayLight,
                labels: RangeLabels(
                  _priceLabel(_price.start),
                  _priceLabel(_price.end),
                ),
                onChanged: _maxBound <= _minBound
                    ? null
                    : (v) => setState(() => _price = v),
              ),
              SizedBox(height: 16.h),

              // ── Distance ───────────────────────────────────────────────
              _label(context, 'discovery_filter_distance'.tr,
                  Icons.near_me_rounded),
              SizedBox(height: 10.h),
              _LocationToggle(controller: widget.controller),
              Obx(() {
                if (!widget.controller.hasUserLocation) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    AppText(
                      text: 'discovery_filter_distance_value'
                          .trParams({'km': (_distanceKm ?? 10).round().toString()}),
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.primary),
                    ),
                    Slider(
                      value: (_distanceKm ?? 10).clamp(1, 50),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.grayLight,
                      onChanged: (v) => setState(() => _distanceKm = v),
                    ),
                  ],
                );
              }),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                child: PrimaryTextButton(
                  appButtonSize: AppButtonSize.large,
                  onTap: _apply,
                  label: AppText(
                    text: 'discovery_filter_apply'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        AppText(
          text: text,
          textStyle: context.typography.smSemiBold
              .copyWith(color: AppColors.textDefault),
        ),
      ],
    );
  }

  String _priceLabel(double v) =>
      '${v.round()} ${'currency'.tr}';

  void _pickAge() {
    final initial = _ageMonths ?? 24;
    int years = (initial ~/ 12).clamp(0, 6);
    int months = initial % 12;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Directionality(
        textDirection: appTextDirection,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: 'discovery_filter_age_pick'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textPrimaryParagraph),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 160.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Wheel(
                          unit: 'age_unit_years'.tr,
                          count: 7,
                          initial: years,
                          onChanged: (v) => years = v,
                        ),
                      ),
                      Expanded(
                        child: _Wheel(
                          unit: 'age_unit_months'.tr,
                          count: 12,
                          initial: months,
                          onChanged: (v) => months = v,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.large,
                    onTap: () {
                      setState(() => _ageMonths = years * 12 + months);
                      Get.back();
                    },
                    label: AppText(
                      text: 'common_done'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _ageMonths = null;
      _price = RangeValues(_minBound, _maxBound);
      _distanceKm = 10;
      _cityId = null;
    });
    widget.controller.clearFilters();
    Get.back();
  }

  void _apply() {
    final priceActive =
        _price.start > _minBound || _price.end < _maxBound;
    widget.controller.applyFilters(
      age: _ageMonths,
      price: priceActive ? _price : null,
      distance:
          widget.controller.hasUserLocation ? _distanceKm : null,
      city: _cityId,
    );
    Get.back();
  }
}

class _CityDropdown extends StatelessWidget {
  final List<CityModel> cities;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _CityDropdown({
    required this.cities,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validId =
        cities.any((c) => c.key == selectedId) ? selectedId : null;
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: validId,
          isExpanded: true,
          icon: Icon(Icons.expand_more_rounded,
              size: 18.sp, color: AppColors.grayMedium),
          borderRadius: BorderRadius.circular(12.r),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: AppText(
                text: 'discovery_filter_city_any'.tr,
                textStyle: context.typography.smMedium
                    .copyWith(color: AppColors.textPrimaryParagraph),
              ),
            ),
            ...cities.map((c) => DropdownMenuItem<String?>(
                  value: c.key,
                  child: AppText(
                    text: c.name,
                    textStyle: context.typography.smMedium
                        .copyWith(color: AppColors.textPrimaryParagraph),
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AgeSelector extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _AgeSelector({
    required this.label,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.child_care_rounded, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: AppText(
                text: label,
                textStyle: context.typography.smMedium
                    .copyWith(color: AppColors.textPrimaryParagraph),
                maxLines: 1,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 18.sp, color: AppColors.grayMedium),
              )
            else
              Icon(Icons.expand_more_rounded,
                  size: 18.sp, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}

class _LocationToggle extends StatelessWidget {
  final DiscoveryController controller;
  const _LocationToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final on = controller.hasUserLocation;
      final loading = controller.locating.value;
      return GestureDetector(
        onTap: loading
            ? null
            : () async {
                if (on) {
                  controller.disableLocation();
                } else {
                  final ok = await controller.enableLocation();
                  if (!ok) {
                    Loader.showError('discovery_location_denied'.tr);
                  }
                }
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: on
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.backgroundNeutral100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: on
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                on ? Icons.location_on_rounded : Icons.location_off_rounded,
                size: 20.sp,
                color: on ? AppColors.primary : AppColors.grayMedium,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppText(
                  text: 'discovery_filter_use_location'.tr,
                  textStyle: context.typography.smMedium.copyWith(
                    color: on
                        ? AppColors.primary
                        : AppColors.textPrimaryParagraph,
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  on ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 20.sp,
                  color: on ? AppColors.primary : AppColors.grayMedium,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.unit,
    required this.count,
    required this.initial,
    required this.onChanged,
  });
  final String unit;
  final int count;
  final int initial;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: initial),
      itemExtent: 38,
      onSelectedItemChanged: onChanged,
      children: List.generate(
        count,
        (i) => Center(
          child: Text(
            '$i $unit',
            style: context.typography.smMedium
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
        ),
      ),
    );
  }
}
