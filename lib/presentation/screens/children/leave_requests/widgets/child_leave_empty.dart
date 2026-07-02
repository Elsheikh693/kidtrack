import '../../../../../index/index_main.dart';

class ChildLeaveEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const ChildLeaveEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.event_busy, size: 40, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 20),
            Text(
              'child_leave_empty_title'.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'child_leave_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
