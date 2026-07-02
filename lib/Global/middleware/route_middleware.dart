import '../../index/index_main.dart';

class AppMiddleware extends GetMiddleware {
  AppMiddleware({super.priority = 1});

  // Routes that bypass all guards
  static const _open = {
    forceUpdateView,
    onBoardView,
    loginView,
    nurseryDiscoveryView,
    nurseryProfileView,
  };

  @override
  RouteSettings? redirect(String? route) {
    if (_open.contains(route)) return null;

    // Force update blocks everything
    if (ForceUpdate().isForceUpdateRequired) {
      return const RouteSettings(name: forceUpdateView);
    }

    // Onboarding must be seen first
    if (!OnboardLocalCheck.isOnboardSeen()) {
      return const RouteSettings(name: onBoardView);
    }

    final session = SessionService();

    // Not logged in → go to nursery discovery
    if (!session.isLoggedIn) {
      return const RouteSettings(name: nurseryDiscoveryView);
    }

    // Logged in and trying to revisit login → go to main
    if (route == loginView) {
      return const RouteSettings(name: mainView);
    }

    return null;
  }
}
