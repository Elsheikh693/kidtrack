import '../../../../../index/index_main.dart';

class SetupItemTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onDelete;

  const SetupItemTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.typography.smSemiBold
                        .copyWith(fontSize: 15, color: const Color(0xFF1F2937))),
                if (subtitle != null)
                  Text(subtitle!,
                      style: context.typography.xsRegular.copyWith(
                          fontSize: 12, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: const Color(0xFFEF4444), size: 20.sp),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
