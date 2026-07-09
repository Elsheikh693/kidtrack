import 'package:get/get.dart';

class Strings {
  // ─── Font ─────────────────────────────────────────────────────────────────
  static const String fontName = "IBM Plex Sans Arabic";

  // ─── Local Storage Keys ───────────────────────────────────────────────────
  static const String user = "user";
  static const String profile = "Profile_key";
  static const String firstOpen = "Storage_device_first_open_key";
  static const String hasSeenOnboard = "hasSeenOnboard";
  static const String forceUpdate = "force_update";
  static const String keyIsLogin = "login";
  static const String userkey = "userkeyLocal";
  static const String fontname = "IBM Plex Sans Arabic";

  // ─── App Store URLs ───────────────────────────────────────────────────────
  static const String urlIos =
      "https://apps.apple.com/us/app/diwan-%D8%AF%D9%8A%D9%88%D8%A7%D9%86%D9%83/id6630387762";
  static const String urlAndroid =
      "https://play.google.com/store/apps/details?id=com.elsheikh.marketingwhats";

  // ─── Activation deep link ─────────────────────────────────────────────────
  // QR codes encode `${activationLinkBase}<CODE>`. Scanning it (camera) hits the
  // Firebase Hosting landing page, which opens the app (universal/app link) or
  // routes to the store. Keep in sync with firebase.json hosting rewrite + the
  // apple-app-site-association / assetlinks paths (`/a/*`).
  static const String activationLinkBase = "https://kidtrack-bed28.web.app/a/";

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String signUp = "Sign Up";
  static const String signIn = "Log in";
  static const String continueText = "Continue";
  static const String email = "Email";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String forgetPassword = "Forgot password?";
  static const String phoneNumber = "Phone number";
  static const String name = "Name";
  static const String or = "or";
  static const String dontHaveAccount = "Don't have an account?";
  static const String haveAccount = "Already have an account?";
  static const String next = "Next";

  // ─── General UI ───────────────────────────────────────────────────────────
  static const String viewAll = "View All";
  static const String categories = "Categories";
  static const String items = "Items";
  static const String search = "Search";
  static const String favorites = "Favorites";
  static const String placeholderImage =
      'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';

  // ─── Status ───────────────────────────────────────────────────────────────
  static const String current = "جاري";
  static const String finished = "منتهية";
  static const String coming = "قادم";
  static const String notPaid = "لم يتم الدفع";
  static const String cancel = "ملغي";

  // ─── Sorting ──────────────────────────────────────────────────────────────
  static const String desc = "DESC";
  static const String asc = "ASC";

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const String indexPagination = "10";

  // ─── Feedback ─────────────────────────────────────────────────────────────
  static String get updateMessage => "Data is updated Successfully".tr;

  static String get deleteMessage => "Data is deleted Successfully".tr;

  // ─── User Roles ───────────────────────────────────────────────────────────
  static const String admin = "admin";
  static const String customer = "customer";
  static const String staff = "staff";

  // ─── Bottom Bar ───────────────────────────────────────────────────────────
  static int bottomBarIndex = 0;
}
