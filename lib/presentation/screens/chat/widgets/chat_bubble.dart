import '../../../../index/index_main.dart';

const _mineBg = Color(0xFF6366F1);
const _theirsBg = Colors.white;
const _ink = Color(0xFF111827);
const _faint = Color(0xFFAEB6C4);

/// A single message bubble. [isOwn] aligns it to the trailing edge and tints it
/// with the accent colour; the other side gets a white card.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isOwn});

  final ChatMessageModel message;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.74.sw),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.fromLTRB(13.w, 9.h, 13.w, 7.h),
        decoration: BoxDecoration(
          color: isOwn ? _mineBg : _theirsBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isOwn ? 4.r : 16.r),
            bottomRight: Radius.circular(isOwn ? 16.r : 4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: context.typography.smRegular.copyWith(
                fontSize: 13.5,
                height: 1.35,
                color: isOwn ? Colors.white : _ink,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _timeLabel(message.createdAt),
              style: context.typography.xsRegular.copyWith(
                fontSize: 9.5,
                color: isOwn ? Colors.white.withValues(alpha: 0.8) : _faint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
