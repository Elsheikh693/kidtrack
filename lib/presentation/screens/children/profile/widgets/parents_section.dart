import '../../../../../index/index_main.dart';
import 'guardian_edit_sheet.dart';

class ParentsSection extends StatelessWidget {
  final ChildProfileController controller;
  const ParentsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final parents = controller.parents;
    return ProfileSectionCard(
      title: 'child_profile_parents'.tr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            if (parents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'child_profile_no_parent'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ),
              )
            else
              for (int i = 0; i < parents.length; i++) ...[
                if (i > 0) const _Divider(),
                _ParentRow(parent: parents[i], controller: controller),
              ],
            const SizedBox(height: 12),
            _AddParentButton(onTap: controller.addParent),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
    );
  }
}

class _AddParentButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddParentButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_rounded,
                size: 18, color: Color(0xFF7C3AED)),
            const SizedBox(width: 8),
            Text(
              'child_profile_add_parent'.tr,
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentRow extends StatelessWidget {
  final ParentModel parent;
  final ChildProfileController controller;
  const _ParentRow({required this.parent, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showGuardianEditSheet(controller, parent),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _ParentAvatar(parent: parent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parent.name,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                if (parent.phone != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    parent.phone!,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ],
                if (parent.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    parent.email!,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit_outlined,
              size: 18, color: Color(0xFF7C3AED)),
        ],
      ),
    );
  }
}

class _ParentAvatar extends StatelessWidget {
  final ParentModel parent;
  const _ParentAvatar({required this.parent});

  @override
  Widget build(BuildContext context) {
    if (parent.hasImage) {
      return AppNetworkImage(
        url: parent.profileImage,
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(24),
        errorWidget: _Initial(name: parent.name),
      );
    }
    return _Initial(name: parent.name);
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '؟',
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
