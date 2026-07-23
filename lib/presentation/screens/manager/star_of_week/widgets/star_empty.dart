import '../../../../../index/index_main.dart';

/// Shown when the branch has no active children to pick from (or a search
/// returns nothing).
class StarEmpty extends StatelessWidget {
  const StarEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          AppText(
            text: 'sotw_empty_children'.tr,
            textAlign: TextAlign.center,
            textStyle: context.typography.smMedium
                .copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
