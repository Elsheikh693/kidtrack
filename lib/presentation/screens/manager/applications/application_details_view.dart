import '../../../../index/index_main.dart';
import 'widgets/approve_appointment_sheet.dart';
import 'widgets/reject_reason_sheet.dart';

/// Read-only full view of a submitted application, mirroring the data the parent
/// entered. The manager reviews everything here, then approves (picking a visit
/// date/time + sending a WhatsApp) or rejects with a reason.
class ApplicationDetailsView extends StatelessWidget {
  final ManagerApplicationsController controller;
  final OnlineApplicationModel application;
  const ApplicationDetailsView({
    super.key,
    required this.controller,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final app = application;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  children: [
                    _statusCard(context),
                    SizedBox(height: 14.h),
                    _childCard(context),
                    SizedBox(height: 14.h),
                    if (app.branchName != null ||
                        app.selectedPackages.isNotEmpty) ...[
                      _branchCard(context),
                      SizedBox(height: 14.h),
                    ],
                    _guardianCard(
                      context,
                      titleKey: 'apply_account_father',
                      icon: Icons.man_rounded,
                      name: app.fatherName,
                      phone: app.fatherPhone,
                      job: app.fatherJob,
                      nationalId: app.fatherNationalId,
                    ),
                    SizedBox(height: 14.h),
                    _guardianCard(
                      context,
                      titleKey: 'apply_account_mother',
                      icon: Icons.woman_rounded,
                      name: app.motherName,
                      phone: app.motherPhone,
                      job: app.motherJob,
                      nationalId: app.motherNationalId,
                    ),
                    if (app.busSubscription) ...[
                      SizedBox(height: 14.h),
                      _busCard(context),
                    ],
                    if ((app.notes ?? '').isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _notesCard(context),
                    ],
                    if (app.assessment != null &&
                        app.assessment!.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _assessmentCard(context),
                    ],
                    if (app.customFields.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _customFieldsCard(context),
                    ],
                    if (app.isRejected &&
                        (app.rejectionReason ?? '').isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _rejectionCard(context),
                    ],
                  ],
                ),
              ),
              _actionBar(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────--

  Widget _header(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textDefault,
          ),
          Expanded(
            child: AppText(
              text: 'apply_details_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status ─────────────────────────────────────────────────────────────--

  Widget _statusCard(BuildContext context) {
    final app = application;
    late final Color color;
    late final String key;
    if (app.isApproved) {
      color = AppColors.activityGreen;
      key = 'apply_status_approved';
    } else if (app.isRejected) {
      color = AppColors.activityRed;
      key = 'apply_status_rejected';
    } else {
      color = AppColors.activityAmberBrand;
      key = 'apply_status_pending';
    }
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText(
                text: 'apply_details_status'.tr,
                textStyle: context.typography.smMedium
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: key.tr,
                  textStyle:
                      context.typography.xsMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (app.isApproved && app.appointmentAt != null) ...[
            SizedBox(height: 12.h),
            _kv(
              context,
              Icons.event_available_rounded,
              'apply_appointment_label'.tr,
              '${ManagerApplicationsController.appointmentDate(app.appointmentAt)} • ${ManagerApplicationsController.appointmentTime(app.appointmentAt)}',
            ),
          ],
        ],
      ),
    );
  }

  // ─── Child ──────────────────────────────────────────────────────────────--

  Widget _childCard(BuildContext context) {
    final app = application;
    final photo = app.childPhoto ?? '';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: photo.isNotEmpty ? appCachedImageProvider(photo) : null,
                child: photo.isEmpty
                    ? Icon(Icons.child_care_rounded,
                        color: AppColors.primary, size: 26.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: app.childFullName,
                      textStyle: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      text: 'apply_step_child_title'.tr,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _kv(context, Icons.wc_rounded, 'apply_field_gender'.tr,
              _genderLabel(app.childGender)),
          _kv(context, Icons.cake_rounded, 'apply_field_dob'.tr,
              _dateLabel(app.childDateOfBirth)),
          _kv(context, Icons.flag_rounded, 'apply_field_nationality'.tr,
              app.childNationality),
          _kv(context, Icons.bloodtype_rounded, 'apply_field_blood_type'.tr,
              app.childBloodType),
          _kv(context, Icons.home_rounded, 'apply_field_address'.tr,
              app.childAddress),
        ],
      ),
    );
  }

  // ─── Branch + packages ──────────────────────────────────────────────────--

  Widget _branchCard(BuildContext context) {
    final app = application;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'apply_review_branch'.tr,
              Icons.account_tree_rounded),
          SizedBox(height: 10.h),
          if ((app.branchName ?? '').isNotEmpty)
            _kv(context, Icons.location_on_rounded, 'apply_review_branch'.tr,
                app.branchName),
          if (app.selectedPackages.isNotEmpty) ...[
            SizedBox(height: 4.h),
            ...app.selectedPackages.map(
              (p) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: p.name,
                        textStyle: context.typography.smRegular
                            .copyWith(color: AppColors.textDefault),
                        maxLines: 1,
                      ),
                    ),
                    AppText(
                      text: '${_money(p.price)} ${'currency'.tr}',
                      textStyle: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 14.h, color: AppColors.grayLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'apply_total_label'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                AppText(
                  text: '${_money(app.totalFees)} ${'currency'.tr}',
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Guardian ───────────────────────────────────────────────────────────--

  Widget _guardianCard(
    BuildContext context, {
    required String titleKey,
    required IconData icon,
    required String name,
    required String phone,
    required String? job,
    required String? nationalId,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, titleKey.tr, icon),
          SizedBox(height: 10.h),
          _kv(context, Icons.person_outline_rounded, 'apply_field_full_name'.tr,
              name),
          _kv(context, Icons.phone_rounded, 'apply_field_phone'.tr, phone),
          _kv(context, Icons.work_outline_rounded, 'apply_field_job'.tr, job),
          _kv(context, Icons.badge_outlined, 'apply_field_national_id'.tr,
              nationalId),
        ],
      ),
    );
  }

  // ─── Notes / rejection ──────────────────────────────────────────────────--

  Widget _notesCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'apply_field_notes'.tr, Icons.notes_rounded),
          SizedBox(height: 8.h),
          AppText(
            text: application.notes!,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.textDefault, height: 1.6),
            maxLines: 1000,
          ),
        ],
      ),
    );
  }

  Widget _customFieldsCard(BuildContext context) {
    final fields = application.customFields;
    const sectionOrder = ['child', 'father', 'mother'];
    const sectionLabelKey = {
      'child': 'apply_step_child_title',
      'father': 'apply_account_father',
      'mother': 'apply_account_mother',
    };
    final grouped = <String, List<ApplicationCustomField>>{};
    for (final f in fields) {
      grouped.putIfAbsent(f.section, () => []).add(f);
    }
    final sections = [
      ...sectionOrder.where(grouped.containsKey),
      ...grouped.keys.where((k) => !sectionOrder.contains(k)),
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'apply_custom_fields_title'.tr,
              Icons.list_alt_rounded),
          SizedBox(height: 10.h),
          for (final section in sections) ...[
            if (sectionLabelKey[section] != null) ...[
              SizedBox(height: 2.h),
              AppText(
                text: sectionLabelKey[section]!.tr,
                textStyle: context.typography.xsMedium
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
              SizedBox(height: 6.h),
            ],
            for (final f in grouped[section]!)
              _kv(context, Icons.fiber_manual_record, f.label, f.value),
          ],
        ],
      ),
    );
  }

  Widget _busCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              context, 'apply_step_bus_title'.tr, Icons.directions_bus_rounded),
          SizedBox(height: 8.h),
          _kv(context, Icons.location_on_outlined, 'apply_bus_address'.tr,
              application.busAddress),
        ],
      ),
    );
  }

  Widget _assessmentCard(BuildContext context) {
    final a = application.assessment!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'apply_step_asmt_title'.tr,
              Icons.assignment_turned_in_rounded),
          SizedBox(height: 12.h),
          ...a.questions.map(
            (q) => _assessmentRow(context, q.text, a.ratings[q.id]),
          ),
          if ((a.notes ?? '').isNotEmpty) ...[
            Divider(height: 18.h, color: AppColors.grayLight),
            _kv(context, Icons.notes_rounded, 'apply_asmt_notes'.tr, a.notes),
          ],
        ],
      ),
    );
  }

  Widget _assessmentRow(BuildContext context, String question, String? rating) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              text: question,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textDefault, height: 1.4),
              maxLines: 4,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _ratingColor(rating).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: AppText(
              text: _ratingLabel(rating),
              textStyle: context.typography.xsMedium
                  .copyWith(color: _ratingColor(rating)),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(String? r) {
    if (r == null) return '—';
    return 'apply_asmt_$r'.tr;
  }

  Color _ratingColor(String? r) {
    switch (r) {
      case 'always':
        return AppColors.activityGreen;
      case 'sometimes':
        return AppColors.activityAmberBrand;
      case 'never':
        return AppColors.activityRed;
      default:
        return AppColors.grayMedium;
    }
  }

  Widget _rejectionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.activityRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'apply_reject_reason'.tr,
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.activityRed),
          ),
          SizedBox(height: 6.h),
          AppText(
            text: application.rejectionReason!,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.activityRed, height: 1.6),
            maxLines: 1000,
          ),
        ],
      ),
    );
  }

  // ─── Action bar ─────────────────────────────────────────────────────────--

  Widget _actionBar(BuildContext context) {
    final app = application;
    if (app.isPending) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _openReject,
                child: _actionBox(context, 'apply_reject_btn',
                    AppColors.activityRed, false, Icons.close_rounded),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: _openApprove,
                child: _actionBox(context, 'apply_approve_btn',
                    AppColors.activityGreen, true, Icons.check_rounded),
              ),
            ),
          ],
        ),
      );
    }
    if (app.isApproved) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: GestureDetector(
          onTap: () => controller.sendWhatsApp(app),
          child: _actionBox(context, 'apply_send_whatsapp',
              const Color(0xFF25D366), true, Icons.chat_rounded),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _openApprove() {
    Get.bottomSheet(
      ApproveAppointmentSheet(
        onConfirm: (appointment) {
          Get.back(); // close sheet
          Get.back(); // back to list
          controller.approve(application, appointment: appointment);
        },
      ),
      isScrollControlled: true,
    );
  }

  void _openReject() {
    Get.bottomSheet(
      RejectReasonSheet(
        onConfirm: (reason) {
          Get.back(); // close sheet
          Get.back(); // back to list
          controller.reject(application, reason);
        },
      ),
      isScrollControlled: true,
    );
  }

  // ─── Shared bits ────────────────────────────────────────────────────────--

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
        SizedBox(width: 10.w),
        AppText(
          text: title,
          textStyle: context.typography.smSemiBold
              .copyWith(color: AppColors.textDefault),
        ),
      ],
    );
  }

  Widget _kv(
      BuildContext context, IconData icon, String label, String? value) {
    if ((value ?? '').trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.grayMedium),
          SizedBox(width: 8.w),
          AppText(
            text: '$label: ',
            textStyle: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          Expanded(
            child: AppText(
              text: value!,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textDefault),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBox(BuildContext context, String labelKey, Color color,
      bool filled, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: filled ? AppColors.white : color),
          SizedBox(width: 6.w),
          AppText(
            text: labelKey.tr,
            textStyle: context.typography.smSemiBold
                .copyWith(color: filled ? AppColors.white : color),
          ),
        ],
      ),
    );
  }

  String _genderLabel(String? g) {
    if (g == 'male') return 'apply_gender_male'.tr;
    if (g == 'female') return 'apply_gender_female'.tr;
    return '';
  }

  String _dateLabel(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
