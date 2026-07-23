import '../../../../index/index_main.dart';

/// KidTrack app-rating prompt — the parent rates the APP itself (not the
/// nursery), driven by a SuperAdmin campaign assigned to their nursery. Shown
/// once per campaign, MANDATORY (no close button, back and barrier-tap
/// disabled). Two-phase like the nursery sheet:
///   Phase 1 (44%): icon + campaign title + stars only.
///   Phase 2 (93%): comment + tags + submit fade in after a star is tapped.
class KidtrackFeedbackPrompt {
  static bool _showing = false;

  /// Called on the parent's app open (from the dashboard, after the nursery
  /// feedback prompt). Skips silently unless the parent's nursery has a live
  /// campaign the parent has not yet answered: local gate first, Firebase as a
  /// cross-device backstop.
  static Future<void> maybeShow() async {
    if (_showing) return;
    final session = SessionService();
    if (!session.isParent) return;
    final uid = session.userId ?? '';
    if (uid.isEmpty) return;
    final nurseryId = session.nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    // Don't nag before the mandatory child-profile onboarding is done.
    if (!await ChildProfileCompletionPrompt.isActiveChildComplete()) return;

    final campaign = await Get.find<KidtrackCampaignService>()
        .activeCampaignForNursery(nurseryId);
    if (campaign == null) return;
    final campaignId = campaign.key ?? '';
    if (campaignId.isEmpty) return;
    if (KidtrackFeedbackGate.isDone(uid, campaignId)) return;

    final alreadyOnServer =
        await Get.find<KidtrackFeedbackService>().hasSubmitted(
      nurseryId: nurseryId,
      campaignId: campaignId,
      parentId: uid,
    );
    if (alreadyOnServer) {
      await KidtrackFeedbackGate.markDone(uid, campaignId);
      return;
    }

    final ctx = Get.context;
    if (ctx == null || _showing) return;
    _showing = true;
    await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => PopScope(
        canPop: false,
        child: _KidtrackFeedbackWidget(campaign: campaign),
      ),
    );
    _showing = false;
  }
}

// ─────────────────────────────────────────────────────────────────
class _KidtrackFeedbackWidget extends StatefulWidget {
  final KidtrackFeedbackCampaignModel campaign;
  const _KidtrackFeedbackWidget({required this.campaign});

  @override
  State<_KidtrackFeedbackWidget> createState() =>
      _KidtrackFeedbackWidgetState();
}

class _KidtrackFeedbackWidgetState extends State<_KidtrackFeedbackWidget> {
  int _rating = 0;
  bool _isExpanded = false;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentCtrl = TextEditingController();
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  static const _compactSize = 0.44;
  static const _fullSize = 0.93;

  // Choices are authored per-campaign by the SuperAdmin (free text), so they're
  // displayed and stored verbatim — no translation keys.
  List<String> get _tagKeys => widget.campaign.tags;

  static const _ratingKeys = [
    "",
    "kidtrack_feedback_rating_1",
    "kidtrack_feedback_rating_2",
    "kidtrack_feedback_rating_3",
    "kidtrack_feedback_rating_4",
    "kidtrack_feedback_rating_5",
  ];

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

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
    final uid = session.userId ?? '';
    final nurseryId = session.nurseryId ?? '';
    final campaignId = widget.campaign.key ?? '';
    final childId = Get.isRegistered<ActiveChildService>()
        ? Get.find<ActiveChildService>().childId.value
        : '';

    final response = KidtrackFeedbackResponseModel(
      key: uid,
      campaignId: campaignId,
      nurseryId: nurseryId,
      parentId: uid,
      parentName:
          session.currentUser?.name ?? 'kidtrack_feedback_parent_fallback'.tr,
      childId: childId.isNotEmpty ? childId : null,
      rating: _rating,
      comment:
          _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      tags: _selectedTags.toList(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await Get.find<KidtrackFeedbackService>().submit(response);
      await KidtrackFeedbackGate.markDone(uid, campaignId);
      if (mounted) Navigator.pop(context);
      Loader.showSuccess('kidtrack_feedback_success'.tr);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
      Loader.showError('kidtrack_feedback_error'.tr);
    }
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
                        if (_tagKeys.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _tagsSection(),
                        ],
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
      child:
          Icon(Icons.favorite_rounded, color: AppColors.primary, size: 34),
    ),
  );

  Widget _title() => Center(
    child: Text(
      widget.campaign.title,
      textAlign: TextAlign.center,
      style: context.typography.lgBold.copyWith(color: AppColors.textDefault),
    ),
  );

  Widget _subtitle() {
    final desc = widget.campaign.description?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Text(
          (desc == null || desc.isEmpty)
              ? "kidtrack_feedback_subtitle".tr
              : desc,
          textAlign: TextAlign.center,
          style: context.typography.xsRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }

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
          "kidtrack_feedback_comment_title".tr,
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
            hintText: "kidtrack_feedback_comment_hint".tr,
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
          "kidtrack_feedback_tags_title".tr,
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
                  tagKey,
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
                "kidtrack_feedback_submit".tr,
                style: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
      ),
    ),
  );
}
