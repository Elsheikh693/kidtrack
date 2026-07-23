import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Global, locale-aware text direction.
///
/// Screens historically hardcoded `TextDirection.rtl` because the app was
/// Arabic-only. Now that Arabic + English are both supported, direction MUST
/// follow the active locale: Arabic → RTL, English → LTR.
///
/// Use this instead of a literal `TextDirection.rtl` anywhere a widget needs an
/// explicit direction (Directionality wrappers, `Text(textDirection: ...)`,
/// etc.). It re-evaluates on every rebuild, so `Get.updateLocale(...)` flips the
/// whole app automatically.
TextDirection get appTextDirection =>
    (Get.locale?.languageCode ?? 'ar') == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
