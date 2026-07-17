import '../../../../../index/index_main.dart';

class ProgramEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const ProgramEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.school_outlined, size: 64.sp, color: Colors.grey.shade300),
        SizedBox(height: 16.h),
        Text(
          'program_empty_title'.tr,
          style: context.typography.mdMedium.copyWith(
            fontSize: 16, color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'program_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFFCBD5E1)),
          ),
        ),
      ],
    ),
  );
}
