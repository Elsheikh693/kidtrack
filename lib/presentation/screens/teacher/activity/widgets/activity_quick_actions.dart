import '../../../../../index/index_main.dart';

class ActivityQuickActions extends StatelessWidget {
  const ActivityQuickActions({
    super.key,
    required this.onPhoto,
    required this.onGroupNote,
    required this.onHomework,
    required this.onEnd,
    this.isUploadingPhoto = false,
    this.isSaving = false,
    this.hasGroupNote = false,
    this.photoCount = 0,
  });

  final VoidCallback onPhoto;
  final VoidCallback onGroupNote;
  final VoidCallback onHomework;
  final VoidCallback onEnd;
  final bool isUploadingPhoto;
  final bool isSaving;
  final bool hasGroupNote;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _QBtn(
            icon: Icons.photo_camera_rounded,
            label: 'صور',
            color: const Color(0xFF0891B2),
            isLoading: isUploadingPhoto,
            badge: photoCount > 0 ? '$photoCount' : null,
            onTap: onPhoto,
          ),
          _QBtn(
            icon: Icons.edit_note_rounded,
            label: 'ملاحظة',
            color: const Color(0xFF7C3AED),
            dot: hasGroupNote,
            onTap: onGroupNote,
          ),
          _QBtn(
            icon: Icons.menu_book_rounded,
            label: 'واجب',
            color: const Color(0xFFD97706),
            onTap: onHomework,
          ),
          _QBtn(
            icon: Icons.stop_circle_rounded,
            label: 'إنهاء',
            color: const Color(0xFFDC2626),
            isLoading: isSaving,
            onTap: isSaving ? () {} : onEnd,
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
    this.dot = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  final bool dot;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isLoading ? 0.05 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: color, strokeWidth: 2),
                            ),
                          )
                        : Icon(icon, color: color, size: 22),
                  ),
                  if (dot)
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  if (badge != null)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          badge!,
                          style: context.typography.xsMedium
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: context.typography.xsMedium
                    .copyWith(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
