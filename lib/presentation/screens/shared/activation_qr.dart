import 'package:qr_flutter/qr_flutter.dart';

import '../../../index/index_main.dart';

/// Printable QR representation of an activation code — the paper that goes home
/// with the child. The QR encodes the deep-link URL (`${activationLinkBase}<code>`)
/// so scanning it with ANY camera lands on the hosting page → opens the app (or
/// routes to the store). The human-readable code sits underneath for manual entry.
class ActivationQr extends StatelessWidget {
  final String code;
  final double size;
  final bool showCode;

  const ActivationQr({
    super.key,
    required this.code,
    this.size = 180,
    this.showCode = true,
  });

  /// What the QR image encodes — the deep link, not the bare code.
  String get _payload => '${Strings.activationLinkBase}$code';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: QrImageView(
            data: _payload,
            version: QrVersions.auto,
            size: size.w,
            gapless: false,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textDefault,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textDefault,
            ),
          ),
        ),
        if (showCode) ...[
          SizedBox(height: 12.h),
          Text(
            code,
            textDirection: TextDirection.ltr,
            style: context.typography.displaySmBold.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
