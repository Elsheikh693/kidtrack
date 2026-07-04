import '../../../../../index/index_main.dart';

/// Parent-facing invitation text is ALWAYS Arabic, independent of the
/// receptionist's UI language, because it is delivered to Arabic-speaking
/// parents over WhatsApp. Only the screen chrome around it is localized.
///
/// [childName] may be a single name or several joined names; pass
/// [multipleChildren] = true so the wording switches from "طفلك" to "أطفالك".
String buildParentInvitationMessage({
  required String parentName,
  required String childName,
  required String nurseryName,
  required String phone,
  bool multipleChildren = false,
}) {
  final parent = parentName.trim().isEmpty ? 'ولي الأمر' : parentName.trim();
  final nursery = nurseryName.trim().isEmpty ? 'الحضانة' : nurseryName.trim();
  final child = childName.trim();
  final childLine = child.isEmpty ? '' : ' ($child)';
  final childWord = multipleChildren ? 'أطفالك' : 'طفلك';

  return 'أهلاً يا $parent 🌷\n\n'
      'فعّلنالك حسابك على تطبيق KidTrack عشان تتابع $childWord$childLine في حضانة $nursery.\n\n'
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
