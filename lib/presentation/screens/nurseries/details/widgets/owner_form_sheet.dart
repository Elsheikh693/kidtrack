import '../../../../../index/index_main.dart';

/// Add / edit an owner. On add the phone becomes the owner's login (email
/// `{phone}@gmail.com`, password == phone) so the phone field is required and
/// validated; on edit the phone is profile-only (login credentials unchanged).
class OwnerFormSheet extends StatefulWidget {
  final UserModel? owner;
  final String nurseryName;
  final Future<bool> Function(String name, String phone) onSubmit;

  const OwnerFormSheet({
    super.key,
    required this.owner,
    required this.nurseryName,
    required this.onSubmit,
  });

  @override
  State<OwnerFormSheet> createState() => _OwnerFormSheetState();
}

class _OwnerFormSheetState extends State<OwnerFormSheet> with KeyboardSheetMixin {
  late final TextEditingController ownerNameCtrl;
  late final TextEditingController ownerPhoneCtrl;

  static final _phoneRx = RegExp(r'^(010|011|012|015)\d{8}$');

  bool get _isEdit => widget.owner != null;

  @override
  void initState() {
    super.initState();
    ownerNameCtrl = TextEditingController(text: widget.owner?.name ?? '');
    ownerPhoneCtrl = TextEditingController(text: widget.owner?.phone ?? '');
  }

  @override
  void dispose() {
    ownerNameCtrl.dispose();
    ownerPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = ownerNameCtrl.text.trim();
    final phone = ownerPhoneCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('nursery_error_owner_name'.tr);
      return;
    }
    if (phone.isEmpty) {
      Loader.showError('nursery_error_owner_phone'.tr);
      return;
    }
    if (!_phoneRx.hasMatch(phone)) {
      Loader.showError('nursery_error_phone_invalid'.tr);
      return;
    }
    final ok = await widget.onSubmit(name, phone);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                _isEdit
                    ? 'nursery_edit_owner_title'.tr
                    : 'nursery_add_owner_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.nurseryName,
                style: context.typography.smRegular.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
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
                    _isEdit
                        ? 'nursery_save_owner_btn'.tr
                        : 'nursery_add_owner_btn'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 16,
                    ),
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
