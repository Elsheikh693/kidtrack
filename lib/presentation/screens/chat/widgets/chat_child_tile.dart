import '../../../../index/index_main.dart';

const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _faint = Color(0xFFAEB6C4);
const _accent = Color(0xFF6366F1);
const _accentBg = Color(0xFFEEF0FE);

/// One row in the manager chat inbox: child photo, name, linked parent, and the
/// last message preview with an unread badge.
class ChatChildTile extends StatelessWidget {
  const ChatChildTile({
    super.key,
    required this.name,
    required this.parentName,
    required this.imageUrl,
    required this.convo,
    required this.onTap,
  });

  final String name;
  final String parentName;
  final String? imageUrl;
  final ChatConversationModel? convo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final unread = convo?.unreadManager ?? 0;
    final last = convo;
    final preview = (last != null && last.hasMessages)
        ? last.lastText
        : 'chat_no_messages'.tr;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
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
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: _accentBg,
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
                      name.isNotEmpty ? name.characters.first : '؟',
                      style: context.typography.mdBold.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: _accent,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: context.typography.displaySmBold.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (last != null && last.hasMessages)
                        Text(
                          _timeLabel(last.lastAt),
                          style: context.typography.xsRegular.copyWith(
                            fontSize: 10.5,
                            color: _faint,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          parentName.isEmpty
                              ? 'chat_no_parent'.tr
                              : '${'chat_parent_prefix'.tr} $parentName',
                          style: context.typography.xsMedium.copyWith(
                            fontSize: 11.5,
                            color: _muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: context.typography.xsRegular.copyWith(
                            fontSize: 12,
                            color: unread > 0 ? _ink : _muted,
                            fontWeight:
                                unread > 0 ? FontWeight.w700 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: context.typography.xsBold.copyWith(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dt.day}/${dt.month}';
  }
}
