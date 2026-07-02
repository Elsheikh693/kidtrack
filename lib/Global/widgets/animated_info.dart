import '../../index/index_main.dart';

class AnimatedInfoMessage extends StatefulWidget {
  final String txt;

  const AnimatedInfoMessage({super.key, required this.txt});

  @override
  State<AnimatedInfoMessage> createState() => _AnimatedInfoMessageState();
}

class _AnimatedInfoMessageState extends State<AnimatedInfoMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: AppColors.tagIconWarning, // ✅ Change to Info Color
              padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
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
