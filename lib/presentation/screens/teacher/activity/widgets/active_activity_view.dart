import '../../../../../index/index_main.dart';
import '../teacher_activity_controller.dart';
import 'activity_header.dart';
import 'activity_photos_section.dart';
import 'activity_states_section.dart';

class ActiveActivityView extends StatelessWidget {
  const ActiveActivityView({
    super.key,
    required this.ctrl,
    required this.activity,
    required this.onEnd,
  });

  final TeacherActivityController ctrl;
  final ClassroomActivityModel activity;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ActivityHeaderDelegate(
                activity: activity,
                classroomName: ctrl.myClassrooms
                    .firstWhereOrNull((c) => c.key == activity.classroomId)
                    ?.name,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos card
                    Obx(() => ActivityPhotosSection(
                          photos: ctrl.activeActivity.value?.photos ?? {},
                          children: ctrl.children,
                          onAdd: ctrl.uploadActivityPhoto,
                          onDelete: ctrl.removeActivityPhoto,
                          onSetAudience: ctrl.setPhotoAudience,
                          isUploading: ctrl.isUploadingPhoto.value,
                        )),
                    const SizedBox(height: 14),

                    // General note card (if exists)
                    Obx(() {
                      final note = ctrl.activeActivity.value?.groupNote;
                      if (note == null || note.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _NoteCard(note: note),
                      );
                    }),

                    // Children live states
                    ActivityStatesSection(ctrl: ctrl),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // Fixed bottom action bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _ActivityActionBar(ctrl: ctrl, onEnd: onEnd),
        ),
      ],
    );
  }
}

// ── General Note Card ────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.activityPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.activityPurple.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.activityPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: AppColors.activityPurple, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'teacher_activity_note_general'.tr,
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.activityPurple),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textDisplay, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────────

class _ActivityActionBar extends StatelessWidget {
  const _ActivityActionBar({required this.ctrl, required this.onEnd});

  final TeacherActivityController ctrl;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Camera button
          Obx(() => _CameraButton(
                isLoading: ctrl.isUploadingPhoto.value,
                photoCount: ctrl.activeActivity.value?.photos.length ?? 0,
                onTap: ctrl.uploadActivityPhoto,
              )),
          const SizedBox(width: 12),
          // End Activity button
          Expanded(
            child: Obx(() => _EndButton(
                  isSaving: ctrl.isSaving.value,
                  onTap: onEnd,
                )),
          ),
        ],
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.isLoading,
    required this.photoCount,
    required this.onTap,
  });

  final bool isLoading;
  final int photoCount;
  final VoidCallback onTap;

  static const _color = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 58,
        height: 52,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withValues(alpha: 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: _color, strokeWidth: 2),
              )
            else
              const Icon(Icons.photo_camera_rounded,
                  color: _color, size: 24),
            if (photoCount > 0 && !isLoading)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: _color, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '$photoCount',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EndButton extends StatelessWidget {
  const _EndButton({required this.isSaving, required this.onTap});

  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          gradient: isSaving
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isSaving ? Colors.grey.shade200 : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.grey),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stop_circle_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'teacher_activity_end_btn'.tr,
                      style: context.typography.mdBold
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
