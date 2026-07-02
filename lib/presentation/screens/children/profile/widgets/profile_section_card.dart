import '../../../../../index/index_main.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Widget child;

  const ProfileSectionCard({
    super.key,
    required this.title,
    this.onAction,
    this.actionLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                if (onAction != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel ?? 'common_view_all'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF7C3AED)),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
        ],
      ),
    );
  }
}
