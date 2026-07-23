import '../../../../index/index_main.dart';

/// SuperAdmin read-only view of one nursery's responses to one KidTrack campaign,
/// plus a professional WhatsApp summary (not raw messages). Reads directly via
/// [KidtrackFeedbackService] with the explicit nursery+campaign passed as args.
class KidtrackFeedbackResponsesController extends GetxController {
  late final KidtrackFeedbackService _service;

  final RxList<KidtrackFeedbackResponseModel> items =
      <KidtrackFeedbackResponseModel>[].obs;
  final RxBool isLoading = true.obs;

  String nurseryId = '';
  String campaignId = '';
  String nurseryName = '';
  String campaignTitle = '';

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<KidtrackFeedbackService>();
    final args = Get.arguments;
    if (args is Map) {
      nurseryId = args['nurseryId']?.toString() ?? '';
      campaignId = args['campaignId']?.toString() ?? '';
      nurseryName = args['nurseryName']?.toString() ?? '';
      campaignTitle = args['campaignTitle']?.toString() ?? '';
    }
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    items.value = await _service.getResponses(
      nurseryId: nurseryId,
      campaignId: campaignId,
    );
    isLoading.value = false;
  }

  int get totalCount => items.length;

  double get averageRating {
    if (items.isEmpty) return 0;
    final sum = items.fold<int>(0, (s, f) => s + f.rating);
    return sum / items.length;
  }

  /// Count of ratings per star value, indexed 1..5 (index 0 unused).
  List<int> get distribution {
    final counts = List<int>.filled(6, 0);
    for (final f in items) {
      if (f.rating >= 1 && f.rating <= 5) counts[f.rating]++;
    }
    return counts;
  }

  /// Tag keys ordered by frequency (most mentioned first).
  List<String> get topTags {
    final counts = <String, int>{};
    for (final f in items) {
      for (final t in f.tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// Compose and send a professional summary through WhatsApp. No fixed
  /// recipient — WhatsApp lets the admin pick (KidTrack management or the owner).
  void shareSummaryToWhatsApp() {
    launchWhatsApp('', message: _buildSummary());
  }

  String _buildSummary() {
    final avg = averageRating.toStringAsFixed(1);
    final buffer = StringBuffer();
    buffer.writeln('📊 ${'kidtrack_summary_header'.tr}');
    if (nurseryName.isNotEmpty) buffer.writeln('🏫 $nurseryName');
    if (campaignTitle.isNotEmpty) buffer.writeln('📣 $campaignTitle');
    buffer.writeln('');
    buffer.writeln('⭐ ${'kidtrack_summary_average'.tr}: $avg / 5');
    buffer.writeln(
        '👥 ${'kidtrack_summary_responses'.tr}: $totalCount');
    buffer.writeln('');

    final tags = topTags.take(3).toList();
    if (tags.isNotEmpty) {
      buffer.writeln('👍 ${'kidtrack_summary_top_tags'.tr}: ${tags.join('، ')}');
      buffer.writeln('');
    }

    final comments = items
        .where((f) => (f.comment ?? '').trim().isNotEmpty)
        .take(3)
        .toList();
    if (comments.isNotEmpty) {
      buffer.writeln('💬 ${'kidtrack_summary_comments'.tr}:');
      for (final c in comments) {
        buffer.writeln('• "${c.comment!.trim()}" — ${c.parentName}');
      }
    }
    return buffer.toString().trim();
  }
}
