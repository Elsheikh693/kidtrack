import '../../../index/index_main.dart';

/// Entry point for the parent WhatsApp icon in the app bar.
///
/// Behaviour:
/// - loads the nursery's configured contact numbers
/// - 0 configured  → falls back to the nursery's main phone (if any)
/// - exactly 1     → opens WhatsApp directly
/// - more than 1   → opens a bottom sheet listing the numbers (name + role)
Future<void> openNurseryWhatsApp() async {
  List<NurseryContactModel> contacts = [];
  try {
    final svc = Get.find<NurseryContactParentService>();
    await svc.getAll(callBack: (list) {
      contacts = list.whereType<NurseryContactModel>().toList()
        ..sort((a, b) {
          if (a.order != b.order) return a.order.compareTo(b.order);
          return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
        });
    });
  } catch (_) {}

  if (contacts.isEmpty) {
    // Fallback to the nursery's single phone number.
    String? phone;
    try {
      final nurserySvc = Get.find<NurseryParentService>();
      await nurserySvc.getAll(callBack: (list) {
        phone = list.whereType<NurseryModel>().firstOrNull?.phone;
      });
    } catch (_) {}

    if (phone != null && phone!.trim().isNotEmpty) {
      await launchWhatsApp(phone!);
    } else {
      Get.snackbar(
        'nursery_contact_title'.tr,
        'nursery_contact_none_available'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.w),
      );
    }
    return;
  }

  if (contacts.length == 1) {
    await launchWhatsApp(contacts.first.phone);
    return;
  }

  Get.bottomSheet(
    _NurseryWhatsAppSheet(contacts: contacts),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

/// Opens WhatsApp chat for [phone] (any format). When [message] is provided it
/// is pre-filled in the chat input, ready to send.
Future<void> launchWhatsApp(String phone, {String? message}) =>
    MakeCall.openWhatsApp(phone, message: message);

class _NurseryWhatsAppSheet extends StatelessWidget {
  final List<NurseryContactModel> contacts;
  const _NurseryWhatsAppSheet({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.chat_rounded,
                      color: const Color(0xFF25D366), size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'nursery_contact_whatsapp_title'.tr,
                        style: context.typography.mdBold.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'nursery_contact_whatsapp_sub'.tr,
                        style: context.typography.xsRegular.copyWith(
                            fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: contacts.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _ContactRow(contact: contacts[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final NurseryContactModel contact;
  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context) {
    final color = Color(contact.colorValue);
    return InkWell(
      onTap: () {
        Get.back();
        launchWhatsApp(contact.phone);
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(contact.icon, color: color, size: 22.sp),
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
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.chat_rounded,
                  color: Colors.white, size: 18.sp),
            ),
          ],
        ),
      ),
    );
  }
}
