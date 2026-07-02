import '../../../../index/index_main.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_hero.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final LoginController controller;
  final _formKey = GlobalKey<FormState>();
  NurseryModel? get _nursery =>
      Get.arguments is NurseryModel ? Get.arguments as NurseryModel : null;
  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  final _scrollController = ScrollController();
  late final AnimationController _animCtrl;
  late final Animation<double> _heroAnim;
  late final Animation<double> _formAnim;

  @override
  void initState() {
    super.initState();
    controller = initController(() => LoginController());
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('login', 2);
    _emailFocus = _keyboardService.getFocusNode(_keys[0]);
    _passwordFocus = _keyboardService.getFocusNode(_keys[1]);
    _emailFocus.addListener(_scrollFocusedIntoView);
    _passwordFocus.addListener(_scrollFocusedIntoView);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _heroAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _formAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearForm();
      _animCtrl.forward();
    });
  }

  // KeyboardActions(disableScroll: true) won't auto-scroll, so the large hero
  // header leaves the focused field hidden behind the keyboard. The form card
  // is the last widget, so scrolling to the bottom reveals every field above
  // the keyboard. Wait for the keyboard inset to settle before scrolling.
  void _scrollFocusedIntoView() {
    if (!_emailFocus.hasFocus && !_passwordFocus.hasFocus) return;
    _scrollToFormWhenKeyboardSettles(0, -1);
  }

  // Poll until the keyboard inset stops growing (settled), then scroll the
  // form fully into view above the keyboard.
  void _scrollToFormWhenKeyboardSettles(int attempt, double lastInset) {
    if (!mounted || attempt > 12) return;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final settled = inset > 0 && inset == lastInset;
    if (!settled) {
      Future.delayed(const Duration(milliseconds: 50),
          () => _scrollToFormWhenKeyboardSettles(attempt + 1, inset));
      return;
    }
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    // Login forces light status-bar icons (dark hero header). Restore the
    // app-wide dark icons when leaving so the next screen isn't left white.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    _emailFocus.removeListener(_scrollFocusedIntoView);
    _passwordFocus.removeListener(_scrollFocusedIntoView);
    _scrollController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusH = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.primary80,
        body: KeyboardActions(
          config: _keyboardService.buildConfig(context, _keys),
          disableScroll: true,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoginHero(
                    statusH: statusH,
                    heroAnim: _heroAnim,
                    nursery: _nursery,
                  ),
                  LoginFormCard(
                    controller: controller,
                    formKey: _formKey,
                    emailFocusNode: _emailFocus,
                    passwordFocusNode: _passwordFocus,
                    bottomPad: bottomPad,
                    formAnim: _formAnim,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
