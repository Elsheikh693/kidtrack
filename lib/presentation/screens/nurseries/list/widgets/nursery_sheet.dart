import 'package:firebase_database/firebase_database.dart';
import '../../../../../index/index_main.dart';

class NurserySheet extends StatefulWidget {
  final NurseryModel? initial;
  const NurserySheet({super.key, this.initial});

  @override
  State<NurserySheet> createState() => _NurserySheetState();
}

class _NurserySheetState extends State<NurserySheet> with KeyboardSheetMixin {
  late final NurseryParentService _service;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final ownerPhoneCtrl = TextEditingController();

  bool get isEdit => widget.initial != null;

  static final _phoneRx = RegExp(r'^(010|011|012|015)\d{8}$');

  @override
  void initState() {
    super.initState();
    _service = Get.find<NurseryParentService>();
    if (isEdit) {
      nameCtrl.text = widget.initial!.name;
      phoneCtrl.text = widget.initial!.phone ?? '';
      addressCtrl.text = widget.initial!.address ?? '';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    ownerNameCtrl.dispose();
    ownerPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!isEdit) {
      final ownerName = ownerNameCtrl.text.trim();
      final ownerPhone = ownerPhoneCtrl.text.trim();
      if (ownerName.isEmpty) {
        Loader.showError('nursery_error_owner_name'.tr);
        return;
      }
      if (ownerPhone.isEmpty) {
        Loader.showError('nursery_error_owner_phone'.tr);
        return;
      }
      if (!_phoneRx.hasMatch(ownerPhone)) {
        Loader.showError('nursery_error_phone_invalid'.tr);
        return;
      }
      await _createWithOwner(ownerName, ownerName, ownerPhone, ownerPhone);
    } else {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        Loader.showError('nursery_error_name'.tr);
        return;
      }
      await _updateNursery(name);
    }
  }

  Future<void> _createWithOwner(
    String name,
    String ownerName,
    String ownerPhone,
    String password,
  ) async {
    Loader.show();
    final nurseryId = const Uuid().v4();

    try {
      // Reuse the identity if this phone already owns a nursery — one person can
      // own several nurseries (an owner membership per nursery).
      final identity = Get.find<IdentityService>();
      final resolved =
          await identity.resolveByPhone(phone: ownerPhone, name: ownerName);
      final ownerUid = resolved.uid;

      await identity.attachMembership(
        uid: ownerUid,
        role: 'owner',
        nurseryId: nurseryId,
        name: ownerName,
        phone: ownerPhone,
      );

      final nursery = NurseryModel(
        key: nurseryId,
        name: name,
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        address: addressCtrl.text.trim().isEmpty
            ? null
            : addressCtrl.text.trim(),
        ownerId: ownerUid,
        isActive: true,
      );

      bool added = false;
      await _service.add(
        item: nursery,
        callBack: (status) async {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            added = true;
          } else {
            await identity.removeMembership(
              uid: ownerUid,
              nurseryId: nurseryId,
              role: 'owner',
            );
            if (resolved.created &&
                (await identity.memberships(ownerUid)).isEmpty) {
              await FirebaseDatabase.instance.ref('users/$ownerUid').remove();
            }
            Loader.showError('nursery_error_failed'.tr);
          }
        },
      );

      if (added) {
        // Mint the owner's durable login code (passwordless) and hand it to the
        // super admin to deliver — same engine as reception→parent.
        final code = await Get.find<ActivationParentService>().generate(
          role: 'owner',
          targetId: ownerUid,
          nurseryId: nurseryId,
          createdBy: SessionService().userId ?? '',
          silent: true,
        );
        Loader.showSuccess('nursery_success_added'.tr);
        Get.back(); // close this sheet first
        if (code != null) {
          unawaited(openActivationSheet(
            code: code,
            recipientName: ownerName,
            phone: ownerPhone,
            nurseryName: name,
          ));
        }
      }
    } catch (_) {
      Loader.dismiss();
      Loader.showError('nursery_error_failed'.tr);
    }
  }

  Future<void> _updateNursery(String name) async {
    final item = widget.initial!.copyWith(
      name: name,
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
    );
    Loader.show();
    await _service.update(
      item: item,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('nursery_success_updated'.tr);
          Get.back();
        } else {
          Loader.showError('nursery_error_failed'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              SizedBox(height: 20.h),
              Text(
                isEdit ? 'nursery_edit_title'.tr : 'nursery_add_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 24.h),
              if (isEdit) ...[
                _SheetLabel('nursery_name_label'.tr),
                SizedBox(height: 6.h),
                _SheetField(controller: nameCtrl, hint: 'nursery_name_hint'.tr),
                SizedBox(height: 14.h),
                _SheetLabel('nursery_phone_label'.tr),
                SizedBox(height: 6.h),
                _SheetField(
                  controller: phoneCtrl,
                  hint: 'nursery_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 14.h),
                _SheetLabel('nursery_address_label'.tr),
                SizedBox(height: 6.h),
                _SheetField(
                  controller: addressCtrl,
                  hint: 'nursery_address_hint'.tr,
                  maxLines: 2,
                ),
              ],
              if (!isEdit)
                NurseryOwnerSection(
                  ownerNameCtrl: ownerNameCtrl,
                  ownerPhoneCtrl: ownerPhoneCtrl,
                ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'nursery_save'.tr,
                    style: context.typography.smSemiBold.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r),
      ),
    ),
  );
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.smMedium.copyWith(
      fontSize: 14,
      color: const Color(0xFF475569),
    ),
  );
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: context.typography.smRegular.copyWith(
      color: const Color(0xFF1E293B),
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(
        color: const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
