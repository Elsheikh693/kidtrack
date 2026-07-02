import '../../../index/index.dart';

class AppLisTile extends StatelessWidget {
  const AppLisTile({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.isThreeLine = false,
    this.dense = false,
    this.selected = false,
    this.tileColor,
    this.iconColor,
    this.contentPadding,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.shape,
    this.clipBehavior = Clip.none,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.focusColor,
    this.hoverColor,
    this.selectedTileColor,
    this.mouseCursor,
    this.autofocus = false,
    this.focusNode,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final bool isThreeLine;
  final bool dense;
  final bool selected;
  final Color? tileColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final OutlinedBorder? shape;
  final Clip clipBehavior;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? selectedTileColor;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      leading: leading,
      trailing: trailing,
      subtitle: subtitle,
      isThreeLine: isThreeLine,
      dense: dense,
      selected: selected,
      tileColor: tileColor ?? context.appListileTheme.tileColor,
      iconColor: iconColor ?? context.appListileTheme.iconColor,
      contentPadding: contentPadding ?? context.appListileTheme.contentPadding,
      horizontalTitleGap:
          horizontalTitleGap ?? context.appListileTheme.horizontalTitleGap,
      minVerticalPadding:
          minVerticalPadding ?? context.appListileTheme.minVerticalPadding,
      shape: shape ?? context.appListileTheme.shape,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      focusColor: focusColor ?? context.appListileTheme.focusColor,
      hoverColor: hoverColor ?? context.appListileTheme.hoverColor,
      selectedTileColor:
          selectedTileColor ?? context.appListileTheme.selectedTileColor,
      mouseCursor: mouseCursor ?? context.appListileTheme.mouseCursor,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}
