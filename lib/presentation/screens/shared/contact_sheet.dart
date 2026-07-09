import '../../../index/index_main.dart';

enum ContactType { nursery, admin, support }

void showContactSheet(ContactType type) {
  Get.bottomSheet(
    _ContactSheet(type: type),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

class _ContactSheet extends StatefulWidget {
  final ContactType type;
  const _ContactSheet({required this.type});

  @override
  State<_ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<_ContactSheet> {
  String? _phone;
  List<NurseryContactModel> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    // Support = the nursery's own contact/emergency numbers, managed by the
    // owner/manager and shown here with call + WhatsApp actions.
    if (widget.type == ContactType.support) {
      try {
        final svc = Get.find<NurseryContactParentService>();
        await svc.getAll(callBack: (list) {
          final items = list.whereType<NurseryContactModel>().toList()
            ..sort((a, b) {
              if (a.order != b.order) return a.order.compareTo(b.order);
              return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
            });
          if (mounted) setState(() => _contacts = items);
        });
      } catch (_) {}
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final service = Get.find<NurseryParentService>();
      await service.getAll(callBack: (list) {
        final nursery = list.whereType<NurseryModel>().firstOrNull;
        if (mounted) {
          setState(() {
            _phone = nursery?.phone;
            _loading = false;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _titleKey {
    switch (widget.type) {
      case ContactType.nursery: return 'contact_nursery_title';
      case ContactType.admin:   return 'nursery_contact_admin_title';
      case ContactType.support: return 'nursery_contact_support_title';
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) => MakeCall.openWhatsApp(phone);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _titleKey.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (widget.type == ContactType.support) ...[
              SizedBox(height: 4.h),
              Text(
                'nursery_contact_support_sub'.tr,
                style: context.typography.xsRegular
                    .copyWith(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
            SizedBox(height: 20.h),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (widget.type == ContactType.support)
              _contacts.isEmpty
                  ? _EmptyPhone()
                  : _SupportContactsList(
                      contacts: _contacts,
                      onCall: _call,
                      onWhatsApp: _whatsapp,
                    )
            else if (_phone == null || _phone!.isEmpty)
              _EmptyPhone()
            else
              _PhoneOptions(phone: _phone!, onCall: _call, onWhatsApp: _whatsapp),
          ],
        ),
      ),
    );
  }
}

class _PhoneOptions extends StatelessWidget {
  final String phone;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onWhatsApp;

  const _PhoneOptions({
    required this.phone,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.phone_rounded,
                  color: const Color(0xFF64748B), size: 18.sp),
              SizedBox(width: 10.w),
              Text(
                phone,
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.phone_rounded,
                label: 'contact_nursery_call'.tr,
                color: AppColors.primary,
                onTap: () => onCall(phone),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ActionBtn(
                icon: Icons.chat_rounded,
                label: 'contact_nursery_whatsapp'.tr,
                color: const Color(0xFF25D366),
                onTap: () => onWhatsApp(phone),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Icon(Icons.phone_disabled_rounded,
                size: 40.sp, color: AppColors.grayMedium),
            SizedBox(height: 10.h),
            Text(
              'contact_nursery_no_phone'.tr,
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportContactsList extends StatelessWidget {
  final List<NurseryContactModel> contacts;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onWhatsApp;

  const _SupportContactsList({
    required this.contacts,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: contacts.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _SupportContactRow(
          contact: contacts[i],
          onCall: onCall,
          onWhatsApp: onWhatsApp,
        ),
      ),
    );
  }
}

class _SupportContactRow extends StatelessWidget {
  final NurseryContactModel contact;
  final Future<void> Function(String) onCall;
  final Future<void> Function(String) onWhatsApp;

  const _SupportContactRow({
    required this.contact,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(contact.colorValue);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(contact.icon, color: color, size: 21.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.name,
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 14.5,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Text(
                          contact.roleLabelTrKey.tr,
                          style: context.typography.smSemiBold.copyWith(
                            fontSize: 11.5,
                            color: color,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            contact.phone,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.xsRegular.copyWith(
                                fontSize: 11.5, color: const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.phone_rounded,
                  label: 'contact_nursery_call'.tr,
                  color: AppColors.primary,
                  onTap: () => onCall(contact.phone),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.chat_rounded,
                  label: 'contact_nursery_whatsapp'.tr,
                  color: const Color(0xFF25D366),
                  onTap: () => onWhatsApp(contact.phone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: context.typography.smSemiBold.copyWith(
                  color: Colors.white, fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
