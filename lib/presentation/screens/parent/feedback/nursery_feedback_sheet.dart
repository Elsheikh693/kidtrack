import '../../../../index/index_main.dart';

/// First-open nursery rating — shown once, MANDATORY (no close button, back and
/// barrier-tap disabled). Two-phase, like the diwanclinic patient sheet:
///   Phase 1 (44%): icon + title + stars only.
///   Phase 2 (93%): comment + tags + submit fade in after a star is tapped.
class NurseryFeedbackPrompt {
  static bool _showing = false;

  /// Called on the parent's first app open (from the dashboard). Skips silently
  /// unless the current parent has never rated: local gate first, Firebase as a
  /// cross-device backstop.
  static Future<void> maybeShow() async {
    if (_showing) return;
    final session = SessionService();
    if (!session.isParent) return;
    final uid = session.userId ?? '';
    if (uid.isEmpty) return;
    if ((session.nurseryId ?? '').isEmpty) return;
    if (NurseryFeedbackGate.isDone(uid)) return;

    // Don't nag for a rating before the mandatory child-profile onboarding is
    // done — that sheet takes priority on first login.
    if (!await ChildProfileCompletionPrompt.isActiveChildComplete()) return;

    final alreadyOnServer = await Get.find<NurseryFeedbackParentService>()
        .hasSubmitted(uid);
    if (alreadyOnServer) {
      await NurseryFeedbackGate.markDone(uid);
      return;
    }

    // Global modal — use the live app context (safe after the async gate above).
    final ctx = Get.context;
    if (ctx == null || _showing) return;
    _showing = true;
    // Get.context is the live app context, fetched fresh after the gate above
    // (not a captured widget context), so it is safe to use here.
    await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) =>
          const PopScope(canPop: false, child: _NurseryFeedbackWidget()),
    );
    _showing = false;
  }
}

// ─────────────────────────────────────────────────────────────────
class _NurseryFeedbackWidget extends StatefulWidget {
  const _NurseryFeedbackWidget();

  @override
  State<_NurseryFeedbackWidget> createState() => _NurseryFeedbackWidgetState();
}

class _NurseryFeedbackWidgetState extends State<_NurseryFeedbackWidget> {
  int _rating = 0;
  bool _isExpanded = false;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentCtrl = TextEditingController();
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  static const _compactSize = 0.44;
  static const _fullSize = 0.93;

  // Stable keys — the key is stored in Firebase; the label is `.tr` for display,
  // so owner/manager sees the right language regardless of the parent's locale.
  static const _tagKeys = [
    "nursery_feedback_tag_care",
    "nursery_feedback_tag_safety",
    "nursery_feedback_tag_communication",
    "nursery_feedback_tag_activities",
    "nursery_feedback_tag_meals",
  ];

  static const _ratingKeys = [
    "",
    "nursery_feedback_rating_1",
    "nursery_feedback_rating_2",
    "nursery_feedback_rating_3",
    "nursery_feedback_rating_4",
    "nursery_feedback_rating_5",
  ];

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  // Tap a star in phase-1 → expand to full screen.
  Future<void> _onStarTap(int star) async {
    setState(() {
      _rating = star;
      _isExpanded = true;
    });
    await Future.delayed(const Duration(milliseconds: 30));
    try {
      await _sheetCtrl.animateTo(
        _fullSize,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  void _onStarChange(int star) => setState(() => _rating = star);

  Future<void> _submit() async {
    if (_isSubmitting || _rating == 0) return;
    setState(() => _isSubmitting = true);

    final session = SessionService();
    final childId = Get.isRegistered<ActiveChildService>()
        ? Get.find<ActiveChildService>().childId.value
        : '';

    final feedback = NurseryFeedbackModel(
      key: session.userId ?? '',
      nurseryId: session.nurseryId ?? '',
      parentId: session.userId ?? '',
      parentName:
          session.currentUser?.name ?? 'nursery_feedback_parent_fallback'.tr,
      childId: childId.isNotEmpty ? childId : null,
      rating: _rating,
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
      tags: _selectedTags.toList(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await Get.find<NurseryFeedbackParentService>().add(
      item: feedback,
      silent: true,
      callBack: (status) async {
        if (status == ResponseStatus.success) {
          await NurseryFeedbackGate.markDone(session.userId ?? '');
          if (mounted) Navigator.pop(context);
          Loader.showSuccess('nursery_feedback_success'.tr);
        } else {
          if (mounted) setState(() => _isSubmitting = false);
          Loader.showError('nursery_feedback_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetCtrl,
      initialChildSize: _compactSize,
      minChildSize: _compactSize,
      maxChildSize: _fullSize,
      snap: true,
      snapSizes: const [_compactSize, _fullSize],
      expand: false,
      builder: (_, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: AppColors.primaryFaint,
            child: ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              children: [
                _handle(),
                const SizedBox(height: 18),
                _icon(),
                const SizedBox(height: 14),
                _title(),
                const SizedBox(height: 6),
                _subtitle(),
                const SizedBox(height: 20),
                _stars(),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  _ratingLabel(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Opacity(opacity: v, child: child),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        _commentSection(),
                        const SizedBox(height: 24),
                        _tagsSection(),
                        const SizedBox(height: 32),
                        _submitBtn(),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── sub-widgets ───────────────────────────────────────────────

  Widget _handle() => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 2),
    child: Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.dividerAndLines,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );

  Widget _icon() => Center(
    child: Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.child_care_rounded, color: AppColors.primary, size: 34),
    ),
  );

  Widget _title() => Center(
    child: Text(
      "nursery_feedback_title".tr,
      textAlign: TextAlign.center,
      style: context.typography.lgBold.copyWith(color: AppColors.textDefault),
    ),
  );

  Widget _subtitle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Center(
      child: Text(
        "nursery_feedback_subtitle".tr,
        textAlign: TextAlign.center,
        style: context.typography.xsRegular.copyWith(
          color: AppColors.textSecondaryParagraph,
        ),
      ),
    ),
  );

  Widget _stars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < _rating;
        return GestureDetector(
          onTap: _isExpanded
              ? () => _onStarChange(i + 1)
              : () => _onStarTap(i + 1),
          child: AnimatedScale(
            scale: filled ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.elasticOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.ratingStar,
                size: 48,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _ratingLabel() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: Text(
      _ratingKeys[_rating].tr,
      key: ValueKey(_rating),
      textAlign: TextAlign.center,
      style: context.typography.smMedium.copyWith(
        color: AppColors.textSecondaryParagraph,
      ),
    ),
  );

  Widget _commentSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "nursery_feedback_comment_title".tr,
          style: context.typography.displaySmBold.copyWith(
            color: AppColors.textDefault,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _commentCtrl,
          maxLines: 4,
          maxLength: 500,
          textDirection: appTextDirection,
          textAlign: TextAlign.right,
          style: context.typography.smRegular.copyWith(
            color: AppColors.textDefault,
          ),
          decoration: InputDecoration(
            hintText: "nursery_feedback_comment_hint".tr,
            hintStyle: context.typography.xsRegular.copyWith(
              color: AppColors.textFieldPlaceholder,
            ),
            counterText: "",
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tagsSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "nursery_feedback_tags_title".tr,
          style: context.typography.displaySmBold.copyWith(
            color: AppColors.textDefault,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: _tagKeys.map((tagKey) {
            final sel = _selectedTags.contains(tagKey);
            return GestureDetector(
              onTap: () => setState(
                () => sel
                    ? _selectedTags.remove(tagKey)
                    : _selectedTags.add(tagKey),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.dividerAndLines,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  tagKey.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: sel
                        ? AppColors.primary
                        : AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );

  Widget _submitBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isSubmitting || _rating == 0) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                "nursery_feedback_submit".tr,
                style: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
      ),
    ),
  );
}
