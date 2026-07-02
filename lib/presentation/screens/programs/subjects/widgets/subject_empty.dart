import '../../../../../index/index_main.dart';

class SubjectEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const SubjectEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('📚', style: context.typography.mdRegular.copyWith(fontSize: 56)),
        SizedBox(height: 16.h),
        Text(
          'subject_empty_title'.tr,
          style: context.typography.mdMedium.copyWith(
            fontSize: 16, color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'subject_empty_subtitle'.tr,
          style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFFCBD5E1)),
        ),
      ],
    ),
  );
}
