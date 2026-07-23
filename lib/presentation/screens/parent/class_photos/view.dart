import 'package:flutter/cupertino.dart';
import '../../../../index/index_main.dart';
import '../../../../Global/services/parent_education_service.dart';
import '../dashboard/widgets/image_viewer.dart';

class ParentClassPhotosView extends StatefulWidget {
  const ParentClassPhotosView({super.key});

  @override
  State<ParentClassPhotosView> createState() => _ParentClassPhotosViewState();
}

class _ParentClassPhotosViewState extends State<ParentClassPhotosView> {
  static const _accent = Color(0xFF6366F1);

  final _edu = ParentEducationService();
  StreamSubscription<List<ClassPhoto>>? _sub;

  late DateTime _selectedDay; // date-only (start of day)
  List<ClassPhoto> _photos = const [];
  bool _loading = true;

  String _nurseryId = '';
  String _classroomId = '';
  String _childId = '';
  String _branchId = '';

  String get _classroomName =>
      (Get.arguments as Map?)?['classroomName'] as String? ?? '';

  List<String> get _fallbackUrls =>
      List<String>.from((Get.arguments as Map?)?['urls'] as List? ?? []);

  bool get _isToday {
    final n = DateTime.now();
    return _selectedDay.year == n.year &&
        _selectedDay.month == n.month &&
        _selectedDay.day == n.day;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _nurseryId = SessionService().nurseryId ?? '';
    final activeChild = Get.find<ActiveChildService>();
    _classroomId = activeChild.classroomId.value;
    _childId = activeChild.childId.value;
    _branchId = activeChild.branchId.value;
    _bindDay();
  }

  void _bindDay() {
    _sub?.cancel();

    // No live source — show whatever urls were passed in (today only).
    if (_nurseryId.isEmpty || _classroomId.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _photos = _isToday
            ? [
                for (final u in _fallbackUrls)
                  ClassPhoto(url: u, takenAt: now, activityTitle: ''),
              ]
            : const [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    _sub = _edu
        .watchPhotosForDay(_nurseryId, _classroomId, _selectedDay, _childId,
            childBranchId: _branchId)
        .listen((photos) {
      if (!mounted) return;
      setState(() {
        // Fall back to passed-in urls only when viewing today + nothing live.
        _photos = (photos.isEmpty && _isToday && _fallbackUrls.isNotEmpty)
            ? [
                for (final u in _fallbackUrls)
                  ClassPhoto(
                      url: u,
                      takenAt: DateTime.now().millisecondsSinceEpoch,
                      activityTitle: ''),
              ]
            : photos;
        _loading = false;
      });
    });
  }

  void _selectDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (d == _selectedDay) return;
    _selectedDay = d;
    _bindDay();
  }

  // ── iOS date picker ─────────────────────────────────────────────────────

  void _openDatePicker() {
    DateTime temp = _selectedDay;
    final now = DateTime.now();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F38),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'اختر اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectDay(temp);
                    },
                    child: const Text(
                      'تم',
                      style: TextStyle(
                        color: Color(0xFF818CF8),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDay,
                  minimumDate: DateTime(2023),
                  maximumDate: DateTime(now.year, now.month, now.day),
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ── Viewer ──────────────────────────────────────────────────────────────

  void _openViewer(int index) {
    final urls = _photos.map((p) => p.url).toList();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) =>
            DailyPhotoViewer(urls: urls, initialIndex: index),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1020),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 236,
              pinned: true,
              backgroundColor: const Color(0xFF0F1230),
              elevation: 0,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CircleButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: Get.back,
                ),
              ),
              title: Text(
                'صور $_classroomName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _PhotosHeader(
                  classroomName: _classroomName,
                  count: _photos.length,
                  dayLabel: _dayLabel(_selectedDay),
                ),
              ),
              bottom: _DaySelectorBar(
                selected: _selectedDay,
                accent: _accent,
                onSelect: _selectDay,
                onPick: _openDatePicker,
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_photos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(isToday: _isToday),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _PhotoTile(
                      photo: _photos[i],
                      index: i,
                      onTap: () => _openViewer(i),
                    ),
                    childCount: _photos.length,
                  ),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
          ],
        ),
      ),
    );
  }
}

// ── Photo tile ────────────────────────────────────────────────────────────────

class _PhotoTile extends StatefulWidget {
  const _PhotoTile({
    required this.photo,
    required this.index,
    required this.onTap,
  });

  final ClassPhoto photo;
  final int index;
  final VoidCallback onTap;

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (widget.index % 9) * 45),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF1A1F38)),
                AppNetworkImage(
                  url: widget.photo.url,
                  fit: BoxFit.cover,
                ),
                // Subtle bottom sheen for depth.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Day selector bar (pinned under the app bar) ─────────────────────────────

class _DaySelectorBar extends StatelessWidget implements PreferredSizeWidget {
  const _DaySelectorBar({
    required this.selected,
    required this.accent,
    required this.onSelect,
    required this.onPick,
  });

  final DateTime selected;
  final Color accent;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPick;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isQuick =
        _isSameDay(selected, today) || _isSameDay(selected, yesterday);

    return Container(
      height: 60,
      color: const Color(0xFF0F1230),
      alignment: Alignment.center,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          _QuickChip(
            label: 'اليوم',
            active: _isSameDay(selected, today),
            accent: accent,
            onTap: () => onSelect(today),
          ),
          _QuickChip(
            label: 'أمس',
            active: _isSameDay(selected, yesterday),
            accent: accent,
            onTap: () => onSelect(yesterday),
          ),
          // Date picker pill — shows the custom-picked day when active.
          _PickerChip(
            label: isQuick ? 'اختر يوم' : _dayLabel(selected),
            active: !isQuick,
            accent: accent,
            onTap: onPick,
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [accent, const Color(0xFF8B5CF6)])
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [accent, const Color(0xFF8B5CF6)])
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 15,
              color: active ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PhotosHeader extends StatelessWidget {
  const _PhotosHeader({
    required this.classroomName,
    required this.count,
    required this.dayLabel,
  });

  final String classroomName;
  final int count;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF1E3A5F),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -30,
            child:
                _Blob(size: 200, color: const Color(0xFF6366F1), opacity: 0.14),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child:
                _Blob(size: 160, color: const Color(0xFF8B5CF6), opacity: 0.12),
          ),
          Positioned(
            top: 40,
            left: 30,
            child:
                _Blob(size: 80, color: const Color(0xFF38BDF8), opacity: 0.10),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight - 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF6366F1).withValues(alpha: 0.5),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'صور $classroomName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Chip(
                          icon: Icons.photo_library_rounded,
                          label: '$count صورة',
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.calendar_today_rounded,
                          label: dayLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isToday});
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.photo_library_outlined,
            color: Colors.white24,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isToday ? 'لا توجد صور اليوم' : 'لا توجد صور في هذا اليوم',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isToday
              ? 'هتلاقي هنا صور أنشطة طفلك أول ما المعلمة تضيفها'
              : 'جرّب تختار يوم تاني من فوق',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

// ── Shared day-label helper ─────────────────────────────────────────────────

const _kArMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String _dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(DateTime(day.year, day.month, day.day)).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  return '${day.day} ${_kArMonths[day.month - 1]}';
}
