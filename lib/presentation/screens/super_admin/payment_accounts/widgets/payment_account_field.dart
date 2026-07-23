import '../../../../../index/index_main.dart';

/// A single labelled input row in the SuperAdmin payment-accounts editor.
class PaymentAccountField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const PaymentAccountField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 6.h),
          AppTextField(
            controller: controller,
            hintText: hint,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}
