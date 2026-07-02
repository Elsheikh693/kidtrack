import '../../index/index_main.dart';
import '../../presentation/screens/owner/executive/widgets/owner_scope_switcher.dart';

/// Plain static app bar for every owner screen. White, non-collapsing, with a
/// title and two actions: notifications and settings. Drop it into
/// `Scaffold.appBar` — it implements [PreferredSizeWidget].
///
/// When [showScopeSwitcher] is true the title is replaced by the global branch
/// scope switcher (the owner's level switch). It auto-hides for single-branch
/// owners, falling back to a plain title.
class OwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OwnerAppBar({
    super.key,
    required this.title,
    this.showScopeSwitcher = false,
    this.onBack,
  });

  final String title;
  final bool showScopeSwitcher;

  /// When provided, a leading back arrow is shown (e.g. when the screen is
  /// opened from a home quick-link rather than the bottom nav bar).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: onBack == null
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textDefault,
              onPressed: onBack,
            ),
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 64,
      title: showScopeSwitcher
          ? const OwnerScopeSwitcher()
          : AppText(
              text: title,
              textStyle: context.typography.lgBold.copyWith(
                color: AppColors.backgroundBlack,
              ),
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textDefault,
          onPressed: () => Get.toNamed(notificationsView),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textDefault,
          onPressed: () => Get.toNamed(settingsView),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
