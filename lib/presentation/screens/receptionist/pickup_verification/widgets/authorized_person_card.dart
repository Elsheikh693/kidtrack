import '../../../../../index/index_main.dart';

class AuthorizedPersonCard extends StatelessWidget {
  final AuthorizedPickupModel person;
  final VoidCallback onConfirm;

  const AuthorizedPersonCard({
    super.key,
    required this.person,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _PersonAvatar(person: person),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault, fontSize: 14),
                  ),
                  Text(
                    'pickup_relation_${person.relationship}'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                  if (person.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      person.phone!,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'pickup_confirm'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final AuthorizedPickupModel person;
  const _PersonAvatar({required this.person});

  @override
  Widget build(BuildContext context) {
    if (person.profileImage != null && person.profileImage!.isNotEmpty) {
      return AppNetworkImage(
        url: person.profileImage,
        width: 56,
        height: 56,
        borderRadius: BorderRadius.circular(28),
        errorWidget: _Initial(name: person.name),
      );
    }
    return _Initial(name: person.name);
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
