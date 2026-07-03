import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Data/models/feed/nursery_post_model.dart';
import '../../../../Global/services/active_child_service.dart';
import '../../../../Global/services/feed_service.dart';
import '../../../../Global/services/parent_engagement_service.dart';
import '../../../../Global/services/session_service.dart';

class ParentFeedController extends GetxController {
  final _service = FeedService();
  final _session = SessionService();
  static const _pageSize = 15;

  // Feed data
  final RxList<NurseryPostModel> _pinnedPosts = <NurseryPostModel>[].obs;
  final RxList<NurseryPostModel> _regularPosts = <NurseryPostModel>[].obs;
  final Rx<PostCategory?> selectedCategory = Rx<PostCategory?>(null);

  // Load state
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  int? _cursor;
  StreamSubscription<List<NurseryPostModel>>? _pinnedSub;
  late final ScrollController scrollController;

  // Posts already reported as seen this session — avoids re-writing on every
  // pagination/stream tick. "Seen" = the parent opened the feed with the post
  // in it (feeds the manager's per-post seen count).
  final Set<String> _seenMarked = <String>{};

  // ── Computed ──────────────────────────────────────────────────────────────

  // A post is visible if it targets everyone (null classroomId) or this
  // child's classroom.
  bool _matchesAudience(NurseryPostModel p) {
    if (p.classroomId == null || p.classroomId!.isEmpty) return true;
    return p.classroomId == Get.find<ActiveChildService>().classroomId.value;
  }

  // Show all-branch posts plus those scoped to the parent's branch.
  // If the parent has no branch set, fall back to showing everything.
  bool _matchesBranch(NurseryPostModel p) {
    final myBranch = _session.branchId;
    if (myBranch == null || myBranch.isEmpty) return true;
    return p.isAllBranches || p.branchIds.contains(myBranch);
  }

  List<NurseryPostModel> get pinnedPosts {
    final cat = selectedCategory.value;
    return _pinnedPosts
        .where(_matchesAudience)
        .where(_matchesBranch)
        .where((p) => cat == null || p.category == cat)
        .toList();
  }

  List<NurseryPostModel> get regularPosts {
    final cat = selectedCategory.value;
    return _regularPosts
        .where(_matchesAudience)
        .where(_matchesBranch)
        .where((p) => cat == null || p.category == cat)
        .toList();
  }

  bool get isEmpty =>
      !isLoading.value && pinnedPosts.isEmpty && regularPosts.isEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    _watchPinned();
    _loadFirst();
    ParentEngagementService().markFeedView();
  }

  @override
  void onClose() {
    _pinnedSub?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  void _watchPinned() {
    _pinnedSub = _service.watchPinnedFeed().listen(
      (list) {
        _pinnedPosts.value = list;
        _markSeen(list);
      },
      onError: (_) {},
    );
  }

  // Report each post the parent can actually see (audience + branch) exactly
  // once per session. Fire-and-forget writes inside the service.
  void _markSeen(Iterable<NurseryPostModel> posts) {
    for (final p in posts) {
      if (_seenMarked.contains(p.id)) continue;
      if (!_matchesAudience(p) || !_matchesBranch(p)) continue;
      _seenMarked.add(p.id);
      _service.markPostSeen(p.id);
    }
  }

  Future<void> _loadFirst() async {
    isLoading.value = true;
    _regularPosts.clear();
    _cursor = null;
    hasMore.value = true;
    await _fetchNext();
    isLoading.value = false;
  }

  Future<void> _fetchNext() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _service.fetchPage(
        beforeTimestamp: _cursor,
        pageSize: _pageSize,
      );
      if (result.posts.isNotEmpty) {
        _regularPosts.addAll(result.posts);
        _markSeen(result.posts);
      }
      if (result.cursor != null) _cursor = result.cursor;
      hasMore.value = result.hasMore;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) _fetchNext();
  }

  @override
  Future<void> refresh() => _loadFirst();

  void filterBy(PostCategory? cat) => selectedCategory.value = cat;

  // ── Time ago helper ───────────────────────────────────────────────────────

  static String timeAgo(int ms) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (d.inSeconds < 60) return 'الآن';
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} دقيقة';
    if (d.inHours < 24) return 'منذ ${d.inHours} ساعة';
    if (d.inDays == 1) return 'أمس';
    if (d.inDays < 7) return 'منذ ${d.inDays} أيام';
    if (d.inDays < 30) return 'منذ ${d.inDays ~/ 7} أسابيع';
    return 'منذ ${d.inDays ~/ 30} شهر';
  }
}
