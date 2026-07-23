import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Read/write of parent responses to a KidTrack app-rating campaign at
/// `platformFeedback/{nurseryId}/{campaignId}/{parentId}`, plus reminder and
/// response-rate helpers.
///
/// Uses direct RTDB access (not the session-scoped 4-layer CRUD): the parent
/// writes their own response (session nurseryId), while the SuperAdmin reads
/// any nursery's responses cross-scope.
class KidtrackFeedbackService {
  final _db = FirebaseDatabase.instance;

  DatabaseReference _responsesRef(String nurseryId, String campaignId) =>
      _db.ref(ApiConstants.platformFeedbackFor(nurseryId, campaignId));

  /// Store a parent's response (keyed by parentId → one answer per campaign).
  Future<void> submit(KidtrackFeedbackResponseModel response) async {
    if (response.nurseryId.isEmpty ||
        response.campaignId.isEmpty ||
        response.parentId.isEmpty) {
      return;
    }
    await _responsesRef(response.nurseryId, response.campaignId)
        .child(response.parentId)
        .set(response.toJson());
  }

  /// True when this parent has already answered this campaign.
  Future<bool> hasSubmitted({
    required String nurseryId,
    required String campaignId,
    required String parentId,
  }) async {
    if (nurseryId.isEmpty || campaignId.isEmpty || parentId.isEmpty) {
      return false;
    }
    final snap =
        await _responsesRef(nurseryId, campaignId).child(parentId).get();
    return snap.exists;
  }

  /// All responses for one nursery+campaign, newest first.
  Future<List<KidtrackFeedbackResponseModel>> getResponses({
    required String nurseryId,
    required String campaignId,
  }) async {
    final result = <KidtrackFeedbackResponseModel>[];
    if (nurseryId.isEmpty || campaignId.isEmpty) return result;
    final snap = await _responsesRef(nurseryId, campaignId).get();
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      map.forEach((k, v) {
        if (v is Map) {
          result.add(KidtrackFeedbackResponseModel.fromJson(
            Map<String, dynamic>.from(v),
            key: k.toString(),
          ));
        }
      });
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  /// Response-rate for a nursery+campaign: total guardians vs. how many answered.
  Future<KidtrackFeedbackStats> getStats({
    required String nurseryId,
    required String campaignId,
  }) async {
    final parents = await _parentUids(nurseryId);
    final responses = await getResponses(
      nurseryId: nurseryId,
      campaignId: campaignId,
    );
    final answeredIds = responses.map((r) => r.parentId).toSet();
    final avg = responses.isEmpty
        ? 0.0
        : responses.fold<int>(0, (s, r) => s + r.rating) / responses.length;
    return KidtrackFeedbackStats(
      totalParents: parents.length,
      answered: answeredIds.length,
      average: avg,
    );
  }

  /// Push a reminder notification to every guardian who has NOT yet answered.
  /// Returns how many reminders were sent.
  Future<int> sendReminders({
    required String nurseryId,
    required String campaignId,
    required String title,
    required String body,
  }) async {
    final parents = await _parentUids(nurseryId);
    if (parents.isEmpty) return 0;
    final responses = await getResponses(
      nurseryId: nurseryId,
      campaignId: campaignId,
    );
    final answered = responses.map((r) => r.parentId).toSet();
    final pending = parents.where((uid) => !answered.contains(uid));

    final sender = NotificationSendService();
    int sent = 0;
    for (final uid in pending) {
      final ok = await sender.sendToUser(
        uid,
        NotificationModel(
          userId: uid,
          nurseryId: nurseryId,
          title: title,
          body: body,
          type: 'general',
          entityId: campaignId,
        ),
      );
      if (ok) sent++;
    }
    return sent;
  }

  /// The uids of a nursery's guardians (parents subtree keys).
  Future<List<String>> _parentUids(String nurseryId) async {
    if (nurseryId.isEmpty) return const [];
    final snap = await _db.ref(ApiConstants.parentsFor(nurseryId)).get();
    final ids = <String>[];
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      for (final k in map.keys) {
        ids.add(k.toString());
      }
    }
    return ids;
  }
}

/// Immutable response-rate snapshot for one nursery+campaign.
class KidtrackFeedbackStats {
  final int totalParents;
  final int answered;
  final double average;

  const KidtrackFeedbackStats({
    required this.totalParents,
    required this.answered,
    required this.average,
  });

  int get waiting => (totalParents - answered).clamp(0, totalParents);
  double get responseRate =>
      totalParents == 0 ? 0.0 : answered / totalParents;
}
