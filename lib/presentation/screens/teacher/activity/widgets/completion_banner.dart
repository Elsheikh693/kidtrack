import '../../../../../index/index_main.dart';

class CompletionBanner extends StatelessWidget {
  const CompletionBanner({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF16A34A)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقييم مكتمل!',
                  style: context.typography.mdBold.copyWith(color: Colors.white),
                ),
                Text(
                  'تم تقييم جميع الطلاب — يمكنك إنهاء النشاط',
                  style: context.typography.xsMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF16A34A),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: onEnd,
            child: Text(
              'إنهاء',
              style: context.typography.xsMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
