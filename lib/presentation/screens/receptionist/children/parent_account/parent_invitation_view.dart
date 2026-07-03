import 'package:firebase_database/firebase_database.dart';
import '../../../../../index/index_main.dart';
import 'parent_status_chip.dart';

/// Parent-facing invitation text is ALWAYS Arabic, independent of the
/// receptionist's UI language, because it is delivered to Arabic-speaking
/// parents over WhatsApp. Only the screen chrome around it is localized.
String buildParentInvitationMessage({
  required String parentName,
  required String childName,
  required String nurseryName,
  required String phone,
}) {
  final parent = parentName.trim().isEmpty ? 'ولي الأمر' : parentName.trim();
  final nursery = nurseryName.trim().isEmpty ? 'الحضانة' : nurseryName.trim();
  final child = childName.trim();
  final childLine = child.isEmpty ? '' : ' ($child)';

  return 'أهلاً يا $parent 🌷\n\n'
      'فعّلنالك حسابك على تطبيق KidTrack عشان تتابع طفلك$childLine في حضانة $nursery.\n\n'
      'من خلال التطبيق هتقدر:\n'
      '✅ تتابع دخول وخروج طفلك.\n'
      '✅ تشوف صور طفلك وأنشطته خلال اليوم.\n'
      '✅ توصلك إعلانات الحضانة أول بأول.\n'
      '✅ تتابع الواجبات والتقييمات.\n'
      '✅ تتواصل مع الحضانة بسهولة.\n\n'
      '🔑 بيانات الدخول:\n'
      'اسم المستخدم: $phone\n'
      'كلمة المرور: $phone\n\n'
      '📲 حمّل التطبيق من هنا:\n'
      'Android: ${Strings.urlAndroid}\n'
      'iPhone: ${Strings.urlIos}\n\n'
      '📌 لو موبايلك آيفون، سجّل رقمنا ده في جهات الاتصال الأول عشان اللينكات تظهرلك وتقدر تضغط عليها.\n\n'
      'ولو حابب تعرف التطبيق بيعمل إيه بالظبط، خُش على حساب الواتساب اللي '
      'بكلّمك منه ده، هتلاقي فيه صور وفيديوهات بتشرحلك كل حاجة خطوة بخطوة. 🌟';
}

class _Guardian {
  final ParentModel parent;
  final String relationship; // 'father' / 'mother' / 'other'
  const _Guardian(this.parent, this.relationship);
}

class ParentInvitationView extends StatefulWidget {
  final String childId;
  final String childName;

  const ParentInvitationView({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ParentInvitationView> createState() => _ParentInvitationViewState();
}

class _ParentInvitationViewState extends State<ParentInvitationView> {
  static const _whatsappGreen = Color(0xFF25D366);

  final _loading = true.obs;
  final _guardians = <_Guardian>[].obs;
  final _sentUids = <String>{}.obs;

  String _nurseryName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _loading.value = true;
    try {
      await Get.find<NurseryParentService>().getAll(
        callBack: (list) {
          final n = list.whereType<NurseryModel>().firstOrNull;
          if (n != null) _nurseryName = n.name;
        },
      );

      final links = <ParentChildModel>[];
      await Get.find<ParentChildParentService>().getAll(
        callBack: (list) => links.addAll(
          list.whereType<ParentChildModel>().where(
            (l) => l.childId == widget.childId,
          ),
        ),
      );

      final parents = <ParentModel>[];
      await Get.find<GuardianParentService>().getAll(
        callBack: (list) => parents.addAll(list.whereType<ParentModel>()),
      );

      final result = <_Guardian>[];
      for (final l in links) {
        final p = parents.firstWhereOrNull((p) => p.uid == l.parentId);
        if (p != null) result.add(_Guardian(p, l.relationship));
      }
      // Father first, then mother, then others.
      result.sort((a, b) => _order(a.relationship).compareTo(
            _order(b.relationship),
          ));
      _guardians.value = result;
    } catch (_) {}
    _loading.value = false;
  }

  int _order(String rel) => switch (rel) {
    'father' => 0,
    'mother' => 1,
    _ => 2,
  };

  String _relLabel(String rel) => switch (rel) {
    'father' => 'guardian_create_relationship_father'.tr,
    'mother' => 'guardian_create_relationship_mother'.tr,
    _ => 'guardian_create_relationship_other'.tr,
  };

  Color _relColor(String rel) => switch (rel) {
    'father' => const Color(0xFF2563EB),
    'mother' => const Color(0xFFDB2777),
    _ => const Color(0xFF64748B),
  };


  void _send(_Guardian g) {
    final phone = g.parent.phone ?? '';
    if (phone.isEmpty) return;
    launchWhatsApp(
      phone,
      message: buildParentInvitationMessage(
        parentName: g.parent.name,
        childName: widget.childName,
        nurseryName: _nurseryName,
        phone: phone,
      ),
    );
    _sentUids.add(g.parent.uid);
    _markInvitationSent(g.parent.uid);
  }

  /// Persists the "invitation sent" timestamp on the parent record so the
  /// onboarding status survives leaving the screen. Fire-and-forget: a failed
  /// write must never block the receptionist. Writes only that one field to
  /// avoid clobbering login telemetry the parent may set concurrently.
  Future<void> _markInvitationSent(String uid) async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;
    // Reflect it locally so the status chip updates immediately.
    final i = _guardians.indexWhere((g) => g.parent.uid == uid);
    if (i != -1) {
      final g = _guardians[i];
      _guardians[i] = _Guardian(
        g.parent.copyWith(invitationSentAt: DateTime.now().millisecondsSinceEpoch),
        g.relationship,
      );
    }
    try {
      await FirebaseDatabase.instance
          .ref('platform/$nurseryId/parents/$uid')
          .update({'invitationSentAt': ServerValue.timestamp});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'rc_invite_title'.tr,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_rounded,
              size: 22.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context),
                      SizedBox(height: 18.h),
                      for (final g in _guardians)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _guardianCard(context, g),
                        ),
                    ],
                  ),
                );
              }),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF7EE),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: const Color(0xFFBFE6C9)),
    ),
    child: Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 24.sp, color: Colors.white),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'rc_invite_ready_title'.tr,
                style: context.typography.displaySmBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF166534),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'rc_invite_created_sub'.tr,
                style: context.typography.xsRegular.copyWith(
                  fontSize: 12.5,
                  color: const Color(0xFF3F8F55),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _guardianCard(BuildContext context, _Guardian g) {
    final color = _relColor(g.relationship);
    final sent = _sentUids.contains(g.parent.uid);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  g.parent.name.isNotEmpty ? g.parent.name[0] : '?',
                  style: context.typography.mdBold.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _relLabel(g.relationship),
                            style: context.typography.smSemiBold.copyWith(
                              fontSize: 11,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      g.parent.name,
                      style: context.typography.mdBold.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      g.parent.phone ?? '',
                      textDirection: TextDirection.ltr,
                      style: context.typography.xsRegular.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ParentStatusChip(status: g.parent.onboardingStatus),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () => _send(g),
              icon: Icon(
                sent ? Icons.done_all_rounded : Icons.chat_rounded,
                size: 19.sp,
              ),
              label: Text(
                sent ? 'rc_invite_resend'.tr : 'rc_invite_send'.tr,
                style: context.typography.displaySmBold.copyWith(
                  fontSize: 14.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: sent
                    ? const Color(0xFF16A34A)
                    : _whatsappGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 14.h),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFEDF0F3))),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'rc_invite_done'.tr,
          style: context.typography.mdBold.copyWith(fontSize: 16),
        ),
      ),
    ),
  );
}
