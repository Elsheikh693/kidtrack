import 'dart:async';

import '../../../../../index/index_main.dart';
import 'star_reveal_view.dart';

/// First-open gate that auto-plays the Star-of-the-Week reveal for a parent —
/// exactly once per pick. Chained after the other mandatory first-open prompts
/// on the parent dashboard, so a fresh star greets every parent the first time
/// they open the app after it was named (and never again for that star).
class StarOfWeekReveal {
  static Future<void> maybeShow() async {
    final uid = SessionService().userId ?? '';
    if (uid.isEmpty) return;

    StarOfWeekModel? star;
    try {
      final completer = Completer<void>();
      Get.find<StarOfWeekParentService>().getAll(callBack: (list) {
        final week = StarOfWeekModel.currentWeekKey();
        final current =
            list.whereType<StarOfWeekModel>().where((s) => s.weekKey == week);
        star = current.isEmpty ? null : current.first;
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () {},
      );
    } catch (_) {
      return;
    }

    final s = star;
    if (s == null) return;

    // Key the "seen" marker on the post id, which is unique per pick — so
    // replacing this week's star (same week key, new post) re-triggers the
    // reveal once for parents who already saw the earlier pick.
    final token = s.postId ?? s.key ?? StarOfWeekModel.idFor(s.branchId, s.weekKey);
    if (StarOfWeekSeen.isSeen(uid, token)) return;

    await StarOfWeekSeen.markSeen(uid, token);
    await showStarReveal(s);
  }
}
