import 'package:flutter_localizations/flutter_localizations.dart';
import 'index/index_main.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    NotificationService.registerBackground();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await StorageService().init();

    // Restore session
    await SessionService().init();

    // Remote config (force update check)
    try {
      await FirebaseRemoteConfigService().checkForceUpdate().timeout(
        const Duration(seconds: 4),
      );
    } catch (_) {}

    Get.put(AppLanguage(), permanent: true);

    Binding().dependencies();

    final app = await ThemeScopeWidget.initialize(const MyApp());

    runApp(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, _) => app,
      ),
    );

    NotificationService().initCore();

    // NOTE: we deliberately do NOT call FlutterNativeSplash.preserve()/remove().
    // preserve() calls RendererBinding.deferFirstFrame(), which holds Flutter's
    // first useful frame deferred. While deferred, every frame produced by a
    // running animation (the nav-bar pill, shimmer, etc.) re-arms
    // `_needToReportFirstFrame`, and the engine's batched FrameTiming reports
    // then invoke the framework's first-frame TimingsCallback with
    // `debugFrameWasSentToEngine == false` — tripping the binding.dart:1280
    // assert on a loop (seen at app open and on every manager tab switch).
    // The OS shows the launch splash and dismisses it automatically on our real
    // first frame; the access gate renders its own neutral surface meanwhile,
    // so holding the splash added no visual value and only caused the flood.
  }, (e, s) => debugPrintStack(stackTrace: s));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KidTrack',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      initialRoute: mainView,
      getPages: Routes.handleRoutes(),
      initialBinding: Binding(),
      themeMode: theme.themeMode,
      theme: ThemeData(extensions: [theme.appTheme]),
      darkTheme: ThemeData(extensions: [theme.appTheme]),
      builder: EasyLoading.init(
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          // App-wide default: dark status-bar icons. Screens that need light
          // icons (e.g. login) override this with their own AnnotatedRegion.
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      translations: Translation(),
    );
  }
}
