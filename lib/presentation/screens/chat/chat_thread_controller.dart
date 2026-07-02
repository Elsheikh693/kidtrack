import '../../../index/index_main.dart';

/// Drives a single conversation thread, shared by both the manager and parent
/// sides. The opening side passes a [ChatConversationModel] meta and its own
/// [senderRole] ('manager' | 'parent') via `Get.arguments`.
class ChatThreadController extends GetxController {
  final _chatService = ChatService();

  late final ChatConversationModel meta;
  late final String senderRole;
  late final String title;
  late final String subtitle;
  String? image;

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final inputCtrl = TextEditingController();

  StreamSubscription<List<ChatMessageModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? const {};
    meta = args['meta'] as ChatConversationModel;
    senderRole = args['senderRole']?.toString() ?? 'manager';
    title = args['title']?.toString() ?? meta.childName;
    subtitle = args['subtitle']?.toString() ?? '';
    image = args['image']?.toString();

    _sub = _chatService.watchMessages(meta.childId).listen((data) {
      messages.value = data;
      isLoading.value = false;
      _chatService.markRead(meta.childId, senderRole);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    inputCtrl.dispose();
    super.onClose();
  }

  bool isOwnMessage(ChatMessageModel m) => m.senderRole == senderRole;

  Future<void> send() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty || isSending.value) return;
    isSending.value = true;
    inputCtrl.clear();
    final ok = await _chatService.sendMessage(
      meta: meta,
      text: text,
      senderRole: senderRole,
    );
    isSending.value = false;
    if (!ok) {
      inputCtrl.text = text;
      Loader.showError('chat_send_failed'.tr);
    }
  }
}
