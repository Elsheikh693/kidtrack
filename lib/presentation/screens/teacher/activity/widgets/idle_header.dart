import '../../../../../index/index_main.dart';
import 'idle_header_delegate.dart';

class IdleHeader extends StatelessWidget {
  const IdleHeader({super.key, required this.ctrl});
  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: IdleHeaderDelegate(ctrl: ctrl, topPadding: topPadding),
    );
  }
}
