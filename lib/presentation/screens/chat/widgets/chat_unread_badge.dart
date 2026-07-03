import '../../../../index/index_main.dart';

/// Small pill badge showing the unread message count on a chat entry point
/// (parent home card / account menu, manager dashboard quick link).
class ChatUnreadBadge extends StatelessWidget {
  const ChatUnreadBadge({super.key, required this.count});

  final int count;

  static const _accent = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 18.w),
      height: 18.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: context.typography.xsBold.copyWith(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
