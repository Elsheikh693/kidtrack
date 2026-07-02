import '../../../index/index_main.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';

const _accent = Color(0xFF6366F1);
const _accentBg = Color(0xFFEEF0FE);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);

/// One conversation, shared by manager and parent. The opening side supplies a
/// meta + senderRole via `Get.arguments` (see [ChatThreadController]).
class ChatThreadView extends StatefulWidget {
  const ChatThreadView({super.key});

  @override
  State<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<ChatThreadView> {
  late final ChatThreadController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChatThreadController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = controller.messages;
                if (msgs.isEmpty) return const _EmptyThread();
                return ListView.builder(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[msgs.length - 1 - i];
                    return ChatBubble(
                      message: m,
                      isOwn: controller.isOwnMessage(m),
                    );
                  },
                );
              }),
            ),
            ChatInputBar(controller: controller),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final hasImage = controller.image != null && controller.image!.isNotEmpty;
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _accentBg,
              shape: BoxShape.circle,
              image: hasImage
                  ? DecorationImage(
                      image: appCachedImageProvider(controller.image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: hasImage
                ? null
                : Text(
                    controller.title.isNotEmpty
                        ? controller.title.characters.first
                        : '؟',
                    style: context.typography.mdBold.copyWith(
                      fontSize: 16,
                      color: _accent,
                    ),
                  ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.title,
                  style: context.typography.mdBold.copyWith(
                    fontSize: 15,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.subtitle.isNotEmpty)
                  Text(
                    controller.subtitle,
                    style: context.typography.xsRegular.copyWith(
                      fontSize: 11.5,
                      color: _muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'chat_thread_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
