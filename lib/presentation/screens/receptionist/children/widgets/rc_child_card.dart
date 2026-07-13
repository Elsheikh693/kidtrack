import '../../../../../index/index_main.dart';

const _morning = Color(0xFFF59E0B);
const _morningBg = Color(0xFFFEF6E7);
const _between = Color(0xFF14B8A6);
const _betweenBg = Color(0xFFE6FAF7);
const _evening = Color(0xFF6366F1);
const _eveningBg = Color(0xFFEEF0FE);
const _ink = Color(0xFF111827);
const _ink2 = Color(0xFF374151);
const _muted = Color(0xFF8A93A4);
const _faint = Color(0xFFAEB6C4);
const _bg = Color(0xFFFAFBFC);
const _green = Color(0xFF16A34A);

class RcChildCard extends StatelessWidget {
  final ChildModel child;
  final String parentName;
  final int extraParents;
  final String classroomName;
  final VoidCallback onTap;
  final VoidCallback onChat;
  final int chatUnread;

  const RcChildCard({
    super.key,
    required this.child,
    required this.parentName,
    this.extraParents = 0,
    required this.classroomName,
    required this.onTap,
    required this.onChat,
    this.chatUnread = 0,
  });

  bool get _hasShift =>
      child.shift == 'morning' ||
      child.shift == 'between' ||
      child.shift == 'evening';
  Color get _accent => switch (child.shift) {
        'evening' => _evening,
        'between' => _between,
        _ => _morning,
      };
  Color get _accentBg => switch (child.shift) {
        'evening' => _eveningBg,
        'between' => _betweenBg,
        _ => _morningBg,
      };
  IconData get _shiftIcon => switch (child.shift) {
        'evening' => Icons.bedtime_rounded,
        'between' => Icons.brightness_6_rounded,
        _ => Icons.wb_sunny_rounded,
      };
  bool get _active => child.status == 'active';
  bool get _hasClass =>
      child.classroomId != null && classroomName != 'child_classroom_none'.tr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 11.h),
        padding: EdgeInsets.fromLTRB(15.w, 13.h, 15.w, 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(
              initial: child.firstName.isNotEmpty
                  ? child.firstName.characters.first
                  : '؟',
              imageUrl: child.profileImage,
              accent: _hasShift ? _accent : _faint,
              accentBg: _hasShift ? _accentBg : _bg,
              shiftIcon: _hasShift ? _shiftIcon : null,
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 14.sp, color: _faint),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          parentName.isEmpty
                              ? 'child_no_parent'.tr
                              : '${'child_parent_prefix'.tr} $parentName',
                          style: context.typography.xsMedium.copyWith(
                            fontSize: 12.5,
                            color: _muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (extraParents > 0) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '+$extraParents',
                            style: context.typography.displaySmBold.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            _ChatBtn(unread: chatUnread, onTap: onChat),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 9.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    color: _active ? _green : _faint,
                    shape: BoxShape.circle,
                    boxShadow: _active
                        ? [
                            BoxShadow(
                              color: _green.withValues(alpha: 0.15),
                              blurRadius: 0,
                              spreadRadius: 3.r,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(height: 9.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 110.w),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _hasClass ? _bg : _morningBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _hasClass ? classroomName : 'child_no_class'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 11,
                        color: _hasClass ? _ink2 : _morning,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBtn extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;

  const _ChatBtn({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
          if (unread > 0)
            Positioned(
              top: -4.h,
              right: -4.w,
              child: ChatUnreadBadge(count: unread),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  final String? imageUrl;
  final Color accent;
  final Color accentBg;
  final IconData? shiftIcon;

  const _Avatar({
    required this.initial,
    this.imageUrl,
    required this.accent,
    required this.accentBg,
    this.shiftIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: accentBg,
              shape: BoxShape.circle,
              image: hasImage
                  ? DecorationImage(
                      image: appCachedImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasImage
                ? null
                : Text(
                    initial,
                    style: context.typography.mdBold.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
          ),
          if (shiftIcon != null)
            Positioned(
              bottom: -2.h,
              left: -2.w,
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Icon(shiftIcon, size: 12.sp, color: accent),
              ),
            ),
        ],
      ),
    );
  }
}
