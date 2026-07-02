import '../../../../../index/index_main.dart';

class DashboardItem {
  final String labelKey;
  final IconData icon;
  final Color color;
  final String route;

  const DashboardItem({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class DashboardSection {
  final String titleKey;
  final IconData titleIcon;
  final Color titleColor;
  final List<DashboardItem> items;

  const DashboardSection({
    required this.titleKey,
    required this.titleIcon,
    required this.titleColor,
    required this.items,
  });
}
