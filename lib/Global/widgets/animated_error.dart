import '../../index/index_main.dart';

class AnimatedErrorMessage extends StatefulWidget {
  final String txt;

  const AnimatedErrorMessage({super.key, required this.txt});

  @override
  State<AnimatedErrorMessage> createState() => _AnimatedErrorMessageState();
}

class _AnimatedErrorMessageState extends State<AnimatedErrorMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // Controls both the slide and fade animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Slide from just above the top (y = -1) down to 0
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      // FadeTransition adds opacity animation
      child: FadeTransition(
        opacity: _controller,
        // SlideTransition animates position from top to in-place
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: AppColors.errorForeground,
              padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.txt,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.mdMedium.copyWith(
                          color: AppColors.white,
                        ),
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
