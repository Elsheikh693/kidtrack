import '../../../index/index_main.dart';

/// Role-agnostic activation-message builder — the single WhatsApp text used to
/// deliver an [ActivationCodeModel.code] to ANY new account (parent, reception,
/// teacher, manager, owner).
///
/// The text is ALWAYS Arabic, independent of the sender's UI language, because
/// it is delivered over WhatsApp to Arabic-speaking recipients. Only the screen
/// chrome around it is localized.
///
/// The activation code IS the login credential — there is no username/password.
/// The recipient enters the code (or scans the QR) and goes straight to Home.
String buildActivationMessage({
  required String role,
  required String name,
  required String code,
  required String nurseryName,
}) {
  final who = name.trim().isEmpty ? _defaultName(role) : name.trim();
  final nursery = nurseryName.trim().isEmpty ? 'الحضانة' : nurseryName.trim();
  final roleLabel = _roleLabel(role);

  final intro = role == 'parent'
      ? 'فعّلنالك حسابك على تطبيق KidTrack عشان تتابع طفلك في حضانة $nursery.'
      : 'فعّلنالك حسابك على تطبيق KidTrack ($roleLabel) في حضانة $nursery.';

  final perks = role == 'parent'
      ? 'من خلال التطبيق هتقدر:\n'
          '✅ تتابع دخول وخروج طفلك.\n'
          '✅ تشوف صور طفلك وأنشطته خلال اليوم.\n'
          '✅ توصلك إعلانات الحضانة أول بأول.\n'
          '✅ تتابع الواجبات والتقييمات.\n'
          '✅ تتواصل مع الحضانة بسهولة.\n\n'
      : '';

  return 'أهلاً يا $who 🌷\n\n'
      '$intro\n\n'
      '$perks'
      '🔑 كود التفعيل بتاعك:\n'
      '$code\n\n'
      '📋 خطوات البداية:\n'
      '1️⃣ افتح التطبيق واكتب الكود ده — أو انسخ الرسالة دي كلها واضغط زر «لصق» جوه خانة الكود، والتطبيق هيطلّع الكود لوحده (أو امسح الـ QR). وهتدخل على طول من غير أي كلمة سر.\n'
      '2️⃣ من داخل التطبيق افتح "المزيد" (أو "الحساب").\n'
      '3️⃣ اختار "تعلّم التطبيق" واتفرّج على الشرح خطوة بخطوة.\n'
      '4️⃣ جرّب بنفسك في التطبيق براحتك 👌\n\n'
      '📲 حمّل التطبيق من هنا:\n'
      'Android: ${Strings.urlAndroid}\n'
      'iPhone: ${Strings.urlIos}\n\n'
      '📌 لو موبايلك آيفون، سجّل رقمنا ده في جهات الاتصال الأول عشان اللينكات تظهرلك وتقدر تضغط عليها.';
}

String _defaultName(String role) => switch (role) {
      'parent' => 'ولي الأمر',
      _ => 'زميلنا',
    };

String _roleLabel(String role) => switch (role) {
      'parent' => 'ولي أمر',
      'reception' => 'استقبال',
      'teacher' => 'معلّم',
      'manager' => 'مدير فرع',
      'owner' => 'صاحب الحضانة',
      _ => 'حساب',
    };
