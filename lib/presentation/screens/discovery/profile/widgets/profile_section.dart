import '../../../../../index/index_main.dart';

/// A profile content block. When [title] is null only the [child] is rendered
/// (used for self-explanatory blocks like the gallery and the about text).
/// [horizontalPadding] lets a section go edge-to-edge (e.g. the gallery).
class ProfileSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final double horizontalPadding;
  const ProfileSection({
    super.key,
    required this.child,
    this.title,
    this.horizontalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding.w,
        0,
        horizontalPadding.w,
        26.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            AppText(
              text: title!,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 14.h),
          ],
          child,
        ],
      ),
    );
  }
}
