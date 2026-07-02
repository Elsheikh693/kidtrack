import '../../../index/index_main.dart';
import 'widgets/onboard_bottom_bar.dart';
import 'widgets/onboard_page.dart';
import 'widgets/onboard_skip_button.dart';

class OnboardView extends StatefulWidget {
  const OnboardView({super.key});

  @override
  State<OnboardView> createState() => _OnboardViewState();
}

class _OnboardViewState extends State<OnboardView> {
  late final OnboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => OnboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardSkipButton(controller: controller),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (_, i) => OnboardPage(data: controller.pages[i]),
              ),
            ),
            OnboardBottomBar(controller: controller),
          ],
        ),
      ),
    );
  }
}
