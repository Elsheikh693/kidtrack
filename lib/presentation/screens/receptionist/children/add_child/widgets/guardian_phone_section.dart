import '../../../../../../index/index_main.dart';
import 'guardian_entry.dart';

/// One guardian card on the add-child form. Merges "search an existing guardian
/// by phone" and "create a new one": type a number → matches show up to link;
/// a new number → a name field appears to create the guardian. Father/mother
/// slots carry a fixed relationship; extra guardians get a relationship toggle
/// and a remove button.
class GuardianSlot extends StatelessWidget {
  final GuardianEntry entry;
  final String headerLabel;
  final List<ParentModel> allParents;
  final Set<String> excludedUids;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const GuardianSlot({
    super.key,
    required this.entry,
    required this.headerLabel,
    required this.allParents,
    required this.excludedUids,
    required this.onChanged,
    this.onRemove,
  });

  List<ParentModel> get _results {
    final raw = entry.phoneCtrl.text.trim();
    if (raw.isEmpty) return const [];
    final normalized = PhoneUtils.normalize(entry.country, raw);
    return allParents.where((p) {
      if (excludedUids.contains(p.uid)) return false;
      final ph = p.phone ?? '';
      return ph.contains(raw) ||
          (normalized.isNotEmpty && ph.contains(normalized));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = entry.phoneCtrl.text.trim().isNotEmpty;
    final selected = entry.selected;
    final results = _results;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                headerLabel,
                style: context.typography.mdBold.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF334155),
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close_rounded,
                      size: 20.sp, color: const Color(0xFF94A3B8)),
                ),
            ],
          ),
          if (!entry.fixedRelationship) ...[
            SizedBox(height: 10.h),
            _relationshipToggle(context),
          ],
          SizedBox(height: 12.h),
          if (selected != null)
            _selectedCard(context, selected)
          else ...[
            Row(
              children: [
                SizedBox(
                  width: 100.w,
                  child: CountryCodePicker(
                    value: entry.country,
                    fillColor: Colors.white,
                    onChanged: (c) {
                      entry.country = c;
                      onChanged();
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(child: _phoneField(context)),
              ],
            ),
            if (results.isNotEmpty) ...[
              SizedBox(height: 10.h),
              for (final p in results) ...[
                _resultRow(context, p),
                SizedBox(height: 8.h),
              ],
            ] else if (hasText) ...[
              SizedBox(height: 12.h),
              _nameField(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _phoneField(BuildContext context) => TextField(
        controller: entry.phoneCtrl,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        inputFormatters: const [EnglishDigitsFormatter()],
        style: context.typography.smRegular
            .copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: _decoration('child_guardian_phone_hint'.tr),
      );

  Widget _nameField(BuildContext context) => TextField(
        controller: entry.nameCtrl,
        keyboardType: TextInputType.name,
        onChanged: (_) => onChanged(),
        style: context.typography.smRegular
            .copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: _decoration('guardian_name_hint'.tr),
      );

  Widget _resultRow(BuildContext context, ParentModel p) => InkWell(
        onTap: () {
          entry.selected = p;
          onChanged();
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  p.name.isNotEmpty ? p.name[0] : '?',
                  style: context.typography.mdBold
                      .copyWith(fontSize: 15, color: AppColors.primary),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: context.typography.smSemiBold.copyWith(
                            fontSize: 14, color: const Color(0xFF111827))),
                    SizedBox(height: 2.h),
                    Text(
                      p.phone ?? '',
                      textDirection: TextDirection.ltr,
                      style: context.typography.xsRegular.copyWith(
                          fontSize: 12.5, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_circle_rounded,
                  color: AppColors.primary, size: 24.sp),
            ],
          ),
        ),
      );

  Widget _selectedCard(BuildContext context, ParentModel p) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 24.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: context.typography.smSemiBold.copyWith(
                          fontSize: 14.5, color: const Color(0xFF111827))),
                  SizedBox(height: 2.h),
                  Text(
                    p.phone ?? '',
                    textDirection: TextDirection.ltr,
                    style: context.typography.xsRegular.copyWith(
                        fontSize: 12.5, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                entry.selected = null;
                entry.phoneCtrl.clear();
                onChanged();
              },
              child: Text(
                'child_guardian_change'.tr,
                style: context.typography.smSemiBold
                    .copyWith(fontSize: 13, color: AppColors.primary),
              ),
            ),
          ],
        ),
      );

  Widget _relationshipToggle(BuildContext context) => Row(
        children: [
          _relChip(context, 'father', 'guardian_create_relationship_father'.tr),
          SizedBox(width: 8.w),
          _relChip(context, 'mother', 'guardian_create_relationship_mother'.tr),
          SizedBox(width: 8.w),
          _relChip(context, 'other', 'guardian_create_relationship_other'.tr),
        ],
      );

  Widget _relChip(BuildContext context, String value, String label) {
    final isSelected = entry.relationship == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          entry.relationship = value;
          onChanged();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 13,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Add another guardian" button below the guardian slots.
class AddGuardianButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddGuardianButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.person_add_alt_1_rounded,
              size: 20.sp, color: AppColors.primary),
          label: Text(
            'child_guardian_add_another'.tr,
            style: context.typography.smSemiBold
                .copyWith(fontSize: 14, color: AppColors.primary),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      );
}

InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
    );
