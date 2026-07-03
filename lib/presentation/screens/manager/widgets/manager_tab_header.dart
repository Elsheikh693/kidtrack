import '../../../../index/index_main.dart';

/// Clean static header shared across the Branch Manager tabs.
/// Title on the leading side, notification action trailing.
/// The white surface bleeds behind the status bar for a premium look.
class ManagerTabHeader extends StatelessWidget {
  const ManagerTabHeader({
    super.key,
    required this.title,
    required this.accent,
    this.subtitle,
    this.onBack,
    this.searchEnabled = false,
    this.searchActive = false,
    this.searchHint,
    this.onSearchToggle,
    this.onSearchChanged,
  });

  final String title;
  final Color accent;
  final String? subtitle;

  /// When provided, a leading back action is shown. Used when the screen is
  /// reached from the home quick-links rather than the bottom nav bar.
  final VoidCallback? onBack;

  /// When true a search action is shown beside the notification/settings icons.
  final bool searchEnabled;

  /// When true the header swaps its title row for an inline search field.
  final bool searchActive;
  final String? searchHint;
  final VoidCallback? onSearchToggle;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 16, 16),
      child: searchActive ? _buildSearchRow(context) : _buildTitleRow(context),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final hasSubtitle = (subtitle ?? '').isNotEmpty;
    return Row(
      key: const ValueKey('manager-header-title'),
      children: [
        if (onBack != null) ...[
          _HeaderAction(
            icon: Icons.arrow_back_ios_new_rounded,
            accent: accent,
            onTap: onBack!,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.typography.xlBold
                    .copyWith(color: AppColors.textDefault),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasSubtitle) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (searchEnabled) ...[
          _HeaderAction(
            icon: Icons.search_rounded,
            accent: accent,
            onTap: onSearchToggle ?? () {},
          ),
          const SizedBox(width: 10),
        ],
        _HeaderAction(
          icon: Icons.notifications_none_rounded,
          accent: accent,
          onTap: () => Get.toNamed(notificationsView),
        ),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      key: const ValueKey('manager-header-search'),
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.textFieldBackgroundFocused,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeaderSearchField(
                    hint: searchHint,
                    onChanged: onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _HeaderAction(
          icon: Icons.close_rounded,
          accent: accent,
          onTap: onSearchToggle ?? () {},
        ),
      ],
    );
  }
}

/// Search input that requests focus *after* the first frame. Using `autofocus`
/// here triggers a focus/keyboard change during build, which leaves render
/// parent-data dirty when the semantics pass runs (framework assertion
/// `!semantics.parentDataDirty`). Post-frame focus avoids that race.
class _HeaderSearchField extends StatefulWidget {
  const _HeaderSearchField({required this.hint, required this.onChanged});

  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  State<_HeaderSearchField> createState() => _HeaderSearchFieldState();
}

class _HeaderSearchFieldState extends State<_HeaderSearchField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      style: context.typography.smRegular.copyWith(color: AppColors.textDefault),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: context.typography.smRegular
            .copyWith(color: AppColors.fieldTextPlaceholder),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accent, size: 21),
      ),
    );
  }
}
