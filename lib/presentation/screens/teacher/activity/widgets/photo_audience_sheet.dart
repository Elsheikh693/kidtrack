import '../../../../../index/index_main.dart';

/// Lets the teacher pick who an activity photo is for: everyone in the class
/// (classroom-wide, the default) or a set of specific children (a private
/// moment). Returns the selected child ids on save — an empty list means
/// classroom-wide.
class PhotoAudienceSheet extends StatefulWidget {
  const PhotoAudienceSheet({
    super.key,
    required this.children,
    required this.initialSelection,
  });

  final List<ChildModel> children;
  final List<String> initialSelection;

  static Future<List<String>?> show(
    BuildContext context, {
    required List<ChildModel> children,
    required List<String> initialSelection,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoAudienceSheet(
        children: children,
        initialSelection: initialSelection,
      ),
    );
  }

  @override
  State<PhotoAudienceSheet> createState() => _PhotoAudienceSheetState();
}

class _PhotoAudienceSheetState extends State<PhotoAudienceSheet> {
  late final Set<String> _selected = {...widget.initialSelection};

  bool get _isEveryone => _selected.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'photo_audience_title'.tr,
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _EveryoneRow(
                  selected: _isEveryone,
                  onTap: () => setState(_selected.clear),
                ),
                const SizedBox(height: 4),
                ...widget.children.map(
                  (c) => _ChildRow(
                    child: c,
                    selected: _selected.contains(c.key),
                    onTap: () => setState(() {
                      final id = c.key ?? '';
                      if (id.isEmpty) return;
                      if (!_selected.remove(id)) _selected.add(id);
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: PrimaryTextButton(
              appButtonSize: AppButtonSize.xxLarge,
              onTap: () => Navigator.pop(context, _selected.toList()),
              label: AppText(
                text: 'photo_audience_save'.tr,
                textStyle: context.typography.mdBold
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EveryoneRow extends StatelessWidget {
  const _EveryoneRow({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AudienceTile(
      selected: selected,
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.groups_rounded, color: AppColors.primary, size: 24),
      ),
      title: 'photo_audience_everyone'.tr,
      subtitle: 'photo_audience_everyone_sub'.tr,
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final ChildModel child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AudienceTile(
      selected: selected,
      onTap: onTap,
      leading: ChildAvatar(
        name: child.fullName,
        imageUrl: child.profileImage,
        size: 44,
      ),
      title: child.fullName,
    );
  }
}

class _AudienceTile extends StatelessWidget {
  const _AudienceTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : const Color(0xFFEEF0F4),
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.typography.xsRegular
                          .copyWith(color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
