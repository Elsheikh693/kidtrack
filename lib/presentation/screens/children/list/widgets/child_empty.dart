import '../../../../../index/index_main.dart';

class ChildEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const ChildEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.child_care, size: 64.sp, color: Colors.grey.shade300),
        SizedBox(height: 16.h),
        Text(
          'child_empty_title'.tr,
          style: context.typography.smMedium.copyWith(
            fontSize: 16, color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'child_empty_subtitle'.tr,
          style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFFCBD5E1)),
        ),
      ],
    ),
  );
}
