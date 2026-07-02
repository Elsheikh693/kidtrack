
import '../../../index/index.dart';

class WhiteStatusBar extends StatelessWidget {
  final Widget child;

  const WhiteStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Makes the status bar background white.
        statusBarIconBrightness: Brightness.dark, // Uses dark icons.
        statusBarBrightness: Brightness.light, // For iOS devices.
      ),
      child: child,
    );
  }
}
