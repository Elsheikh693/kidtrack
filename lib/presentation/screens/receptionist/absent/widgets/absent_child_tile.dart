import '../../../../../index/index_main.dart';

const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _amber = Color(0xFFF59E0B);
const _waGreen = Color(0xFF25D366);

// WhatsApp glyph (embedded so no asset/font dependency is needed).
const _waSvg =
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#fff" d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51l-.57-.01c-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.885-9.885 9.885M20.52 3.449C18.24 1.245 15.24 0 12.045 0 5.463 0 .104 5.334.101 11.892c0 2.096.549 4.14 1.595 5.945L0 24l6.335-1.652a12.062 12.062 0 005.7 1.448h.005c6.585 0 11.946-5.335 11.949-11.893a11.821 11.821 0 00-3.467-8.454"/></svg>';

/// A single absent child inside the "absent today" section: photo, name, linked
/// parent, a WhatsApp shortcut (pre-filled note to the guardian's number) and a
/// chat shortcut to open the in-app conversation.
class AbsentChildTile extends StatelessWidget {
  final ChildModel child;
  final String parentName;
  final VoidCallback onChat;

  /// Opens WhatsApp to the guardian with the caring note pre-filled. Only shown
  /// when [hasPhone] is true (a guardian number is on file).
  final VoidCallback? onWhatsApp;
  final bool hasPhone;

  const AbsentChildTile({
    super.key,
    required this.child,
    required this.parentName,
    required this.onChat,
    this.onWhatsApp,
    this.hasPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChat,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _amber.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            ChildAvatar(
              name: child.fullName,
              imageUrl: child.profileImage,
              size: 42,
              color: _amber,
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 14,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    parentName.isEmpty
                        ? 'child_no_parent'.tr
                        : '${'child_parent_prefix'.tr} $parentName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsMedium.copyWith(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            if (hasPhone && onWhatsApp != null) ...[
              SizedBox(width: 8.w),
              _RoundBtn(
                bg: _waGreen,
                onTap: onWhatsApp!,
                child: SvgPicture.string(_waSvg, width: 19.sp, height: 19.sp),
              ),
            ],
            SizedBox(width: 8.w),
            _RoundBtn(
              bg: AppColors.primary.withValues(alpha: 0.10),
              onTap: onChat,
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 17.sp,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final Color bg;
  final Widget child;
  final VoidCallback onTap;

  const _RoundBtn({required this.bg, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36.w,
        height: 36.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}
