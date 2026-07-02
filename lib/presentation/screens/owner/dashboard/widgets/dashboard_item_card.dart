import '../../../../../index/index_main.dart';
import 'dashboard_item_model.dart';

class DashboardItemCard extends StatelessWidget {
  const DashboardItemCard({super.key, required this.item});

  final DashboardItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.color.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color,
                      item.color.withValues(alpha: 0.70),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(item.icon, size: 23, color: Colors.white),
              ),
              const SizedBox(height: 9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  item.labelKey.tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color.darken(0.18),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
