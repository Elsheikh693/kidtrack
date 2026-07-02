import '../../../../index/index_main.dart';

const _accent = Color(0xFF6366F1);

/// The bottom compose row: a rounded text field plus a circular send button.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key, required this.controller});

  final ChatThreadController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TextField(
                  controller: controller.inputCtrl,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: context.typography.smRegular.copyWith(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'chat_input_hint'.tr,
                    hintStyle: context.typography.smRegular.copyWith(
                      color: const Color(0xFFAEB6C4),
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Obx(() {
              final sending = controller.isSending.value;
              return GestureDetector(
                onTap: sending ? null : controller.send,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                  child: sending
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.send_rounded,
                          color: Colors.white, size: 20.sp),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
