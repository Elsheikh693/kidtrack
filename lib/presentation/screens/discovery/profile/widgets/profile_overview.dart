import '../../../../../index/index_main.dart';

/// "Key facts" card on the nursery profile: accepted age range, the monthly
/// price the nursery starts from, and the application (file-opening) fee — or a
/// Free Application badge. Mirrors the data the manager fills in on their
/// profile and that Discovery filters on.
class ProfileOverview extends StatelessWidget {
  final NurseryModel nursery;

  const ProfileOverview({super.key, required this.nursery});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    final age = _ageRangeLabel();
    if (age != null) {
      rows.add(
        _OverviewRow(
          icon: Icons.cake_rounded,
          color: AppColors.primary,
          label: 'discovery_overview_age'.tr,
          value: age,
        ),
      );
    }

    if (nursery.applicationFeeFree) {
      rows.add(
        _OverviewRow(
          icon: Icons.card_giftcard_rounded,
          color: AppColors.activityGreen,
          label: 'discovery_overview_app_fee'.tr,
          value: 'discovery_free_application'.tr,
          valueColor: AppColors.activityGreen,
        ),
      );
    } else if (nursery.applicationFee != null) {
      rows.add(
        _OverviewRow(
          icon: Icons.description_rounded,
          color: AppColors.primary,
          label: 'discovery_overview_app_fee'.tr,
          value: '${nursery.applicationFee!.round()} ${'currency'.tr}',
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }

  String? _ageRangeLabel() {
    final from = nursery.minAgeMonths;
    final to = nursery.maxAgeMonths;
    if (from == null && to == null) return null;
    if (from != null && to != null) {
      return 'discovery_age_range'.trParams({
        'from': _ageUnit(from),
        'to': _ageUnit(to),
      });
    }
    return _ageUnit(from ?? to!);
  }

  String _ageUnit(int months) {
    final y = months ~/ 12;
    final m = months % 12;
    if (y > 0 && m > 0) {
      return 'age_years_months'.trParams({'y': '$y', 'm': '$m'});
    }
    if (y > 0) return 'age_years'.trParams({'n': '$y'});
    return 'age_months'.trParams({'n': '$m'});
  }
}

class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color? valueColor;

  const _OverviewRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 19.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              text: label,
              textStyle: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          AppText(
            text: value,
            textStyle: context.typography.smSemiBold.copyWith(
              color: valueColor ?? AppColors.textDefault,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
