import '../../index/index_main.dart';

/// Compact country selector (dial code) for international phone fields.
/// Shared by the guardian-phone and staff-phone flows.
///
/// Note: no emoji flags — the app's Arabic font renders regional-indicator
/// glyphs as tofu ("?"), so the collapsed field shows the dial code and the
/// menu shows the country name + dial code.
class CountryCodePicker extends StatelessWidget {
  final PhoneCountry value;
  final ValueChanged<PhoneCountry> onChanged;
  final Color fillColor;

  const CountryCodePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.fillColor = const Color(0xFFF8FAFC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PhoneCountry>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(12.r),
          style: context.typography.smSemiBold
              .copyWith(fontSize: 14, color: const Color(0xFF1E293B)),
          // Collapsed: just the dial code, so it never overflows the narrow box.
          selectedItemBuilder: (_) => PhoneUtils.countries
              .map(
                (c) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '+${c.dialCode}',
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              )
              .toList(),
          items: PhoneUtils.countries
              .map(
                (c) => DropdownMenuItem<PhoneCountry>(
                  value: c,
                  child: Text(
                    '${c.nameKey.tr}  +${c.dialCode}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (c) {
            if (c != null) onChanged(c);
          },
        ),
      ),
    );
  }
}
