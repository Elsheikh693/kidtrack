import '../../../../../index/index_main.dart';
import 'dashboard_item_card.dart';
import 'dashboard_item_model.dart';

class DashboardSectionWidget extends StatelessWidget {
  const DashboardSectionWidget({super.key, required this.section});

  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: section.titleColor.withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(section: section),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const columns = 3;
                    const spacing = 10.0;
                    final itemWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) / columns;
                    final itemHeight = itemWidth / 0.92;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: section.items
                          .map((item) => SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: DashboardItemCard(item: item),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            section.titleColor.withValues(alpha: 0.13),
            section.titleColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        border: Border(
          bottom: BorderSide(
            color: section.titleColor.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  section.titleColor,
                  section.titleColor.withValues(alpha: 0.72),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: section.titleColor.withValues(alpha: 0.38),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(section.titleIcon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              section.titleKey.tr,
              style: TextStyle(
                color: section.titleColor.darken(0.12),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: section.titleColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${section.items.length}',
              style: TextStyle(
                color: section.titleColor.darken(0.05),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
