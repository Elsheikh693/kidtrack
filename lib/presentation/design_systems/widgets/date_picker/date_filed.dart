

import '../../../../index/index_main.dart';

class DateField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? icon;
  final TextEditingController controller;
  final VoidCallback onpress;

  const DateField({
    super.key,
    required this.label,
    this.icon,
    this.hint,
    required this.controller,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.smRegular.copyWith(
            color: AppColors.textDisplay,
          ), // Update based on your theme
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AppTextField(
            showShadow: false,
            controller: controller,
            prefixIcon:
                icon != null ? const Icon(Icons.calendar_today_outlined) : null,
            hintText: hint ?? 'binding9_choose_date'.tr,
            ontap: () async {
              Get.bottomSheet(
                Container(
                  color: Colors.white,
                  child: GenericDatePicker(
                    onDateSelected: (value) {
                      controller.text = value.toString();

                      // DateTime date = DateTime.fromMillisecondsSinceEpoch(value);
                      // String time12 = DateFormat('h:mm a').format(date);
                      // controller.text = time12;

                      onpress();
                    },
                  ),
                ),
              );
            },
            readOnly: true,
          ),
        ),
      ],
    );
  }
}
