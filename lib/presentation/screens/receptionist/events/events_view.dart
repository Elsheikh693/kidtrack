import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';
import 'events_controller.dart';
import 'widgets/create_event_sheet.dart';
import 'widgets/event_attendees_sheet.dart';

// ── Palette ─────────────────────────────────────────────────────────────────────
const _indigo = Color(0xFF6366F1);
const _violet = Color(0xFF8B5CF6);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _faint = Color(0xFF94A3B8);
const _bg = Color(0xFFF6F7FB);
const _line = Color(0xFFE9EDF3);

class ReceptionistEventsView extends StatefulWidget {
  const ReceptionistEventsView({super.key});

  @override
  State<ReceptionistEventsView> createState() => _ReceptionistEventsViewState();
}

class _ReceptionistEventsViewState extends State<ReceptionistEventsView> {
  late final ReceptionistEventsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ReceptionistEventsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: _bg,
        // Lift the FAB clear of MainPage's floating bottom nav bar (this is a
        // nested Scaffold, so its FAB otherwise overlaps the parent nav).
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 80.h),
          child: _GradientFab(onPressed: () => _showCreate(context)),
        ),
        body: Column(
          children: [
            AppTitleBar(
              title: 'event_title'.tr,
              onNotificationTap: () => Get.toNamed(notificationsView),
              onSettingsTap: () => Get.toNamed(settingsView),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _indigo),
                  );
                }
                return Column(
                  children: [
                    _FilterSegment(controller: controller),
                    Expanded(
                      child: _EventsList(
                        controller: controller,
                        onCreate: () => _showCreate(context),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateEventSheet(),
    );
  }
}

// ── Gradient FAB ─────────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_indigo, _violet],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _indigo.withValues(alpha: 0.35),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'event_add'.tr,
              style: context.typography.displaySmBold.copyWith(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segmented filter ─────────────────────────────────────────────────────────────

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({required this.controller});
  final ReceptionistEventsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final upcoming = controller.filterUpcoming.value;
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            _seg('event_filter_upcoming'.tr, upcoming, () {
              if (!upcoming) controller.toggleFilter();
            }),
            _seg('event_filter_all'.tr, !upcoming, () {
              if (upcoming) controller.toggleFilter();
            }),
          ],
        ),
      );
    });
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_indigo, _violet])
                : null,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _muted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── List + empty ─────────────────────────────────────────────────────────────────

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.controller,
    required this.onCreate,
  });
  final ReceptionistEventsController controller;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredEvents;
      if (list.isEmpty) return _EmptyState(onCreate: onCreate);
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 160.h),
        itemCount: list.length,
        itemBuilder: (_, i) => _EventCard(
          event: list[i],
          controller: controller,
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _indigo.withValues(alpha: 0.12),
                    _violet.withValues(alpha: 0.12),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded,
                  size: 44.sp, color: _indigo),
            ),
            SizedBox(height: 20.h),
            Text(
              'event_empty'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'event_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: context.typography.xsRegular.copyWith(
                fontSize: 13,
                color: _faint,
                height: 1.5,
              ),
            ),
            SizedBox(height: 22.h),
            GestureDetector(
              onTap: onCreate,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_indigo, _violet]),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: _indigo.withValues(alpha: 0.3),
                      blurRadius: 14.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        color: Colors.white, size: 20.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'event_add'.tr,
                      style: context.typography.displaySmBold.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event card ───────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.controller,
  });
  final NurseryEventModel event;
  final ReceptionistEventsController controller;

  bool get _hasCover =>
      event.coverImage != null && event.coverImage!.isNotEmpty;
  bool get _past => !event.isUpcoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _indigo.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hasCover ? _coverHero(context) : _plainHero(context),
            _body(context),
          ],
        ),
      ),
    );
  }

  // ── Hero (cover image or category-tinted banner) ──────────────────────────

  Widget _coverHero(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(staffEventPhotosView, arguments: event),
      child: _hero(
        context,
        background: AppNetworkImage(
          url: event.coverImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _plainHero(BuildContext context) {
    final color = event.category.color;
    return _hero(
      context,
      background: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [color, Color.lerp(color, Colors.black, 0.28)!],
          ),
        ),
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
            child: Icon(
              event.category.icon,
              size: 120.sp,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, {required Widget background}) {
    return SizedBox(
      height: 190.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          background,
          // Legibility scrim — light at the top for the badges, heavy at the
          // bottom for the title + meta.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.28, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 12.h,
            left: 12.w,
            right: 12.w,
            child: Row(
              children: [
                _categoryBadge(),
                const Spacer(),
                if (_past) ...[
                  _statusPill('event_past'.tr),
                  SizedBox(width: 8.w),
                ],
                _MenuButton(onSelected: (v) => _onMenu(context, v)),
              ],
            ),
          ),
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 14.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.photos.isNotEmpty) ...[
                  _glassChip(
                    Icons.photo_library_rounded,
                    '${event.photos.length} ${'event_photos_count_suffix'.tr}',
                  ),
                  SizedBox(height: 9.h),
                ],
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.mdBold.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8.h),
                _metaRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    return Wrap(
      spacing: 14.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaItem(Icons.calendar_today_rounded, event.formattedDate),
        if (event.timeStr != null && event.timeStr!.isNotEmpty)
          _metaItem(Icons.access_time_rounded, event.timeStr!),
        if (event.location != null && event.location!.isNotEmpty)
          _metaItem(Icons.location_on_rounded, event.location!),
      ],
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: Colors.white.withValues(alpha: 0.9)),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }

  // ── Body (description + action footer) ────────────────────────────────────

  Widget _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.description.isNotEmpty) ...[
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsRegular.copyWith(
                fontSize: 12.5,
                color: _muted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          if (event.createdByName.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.person_rounded, size: 13.sp, color: _faint),
                SizedBox(width: 5.w),
                Text(
                  event.createdByName,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _faint,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
          Container(height: 1, color: _line),
          SizedBox(height: 12.h),
          Row(
            children: [
              _attendeesButton(context),
              const Spacer(),
              _photosButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendeesButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAttendees(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: _indigo.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_rounded, size: 15.sp, color: _indigo),
            SizedBox(width: 6.w),
            Text(
              '${event.attendeesCount}',
              style: context.typography.displaySmBold.copyWith(
                fontSize: 13,
                color: _indigo,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'event_interested_suffix'.tr,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _indigo.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(width: 3.w),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 10.sp, color: _indigo.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _photosButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(staffEventPhotosView, arguments: event),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_indigo, _violet]),
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: [
            BoxShadow(
              color: _indigo.withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_rounded, size: 14.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              'event_photos_title'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero pills ────────────────────────────────────────────────────────────

  Widget _categoryBadge() {
    final color = event.category.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(event.category.icon, size: 13.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            event.category.labelKey.tr,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _glassChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openAttendees(BuildContext context) {
    controller.watchAttendeesFor(event.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventAttendeesSheet(event: event, controller: controller),
    ).whenComplete(controller.stopWatchingAttendees);
  }

  void _onMenu(BuildContext context, String action) {
    switch (action) {
      case 'photos':
        Get.toNamed(staffEventPhotosView, arguments: event);
        break;
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CreateEventSheet(editEvent: event),
        );
        break;
      case 'attendees':
        _openAttendees(context);
        break;
      case 'delete':
        Get.dialog(AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: Text('event_delete_confirm_title'.tr),
          content: Text('event_delete_confirm_body'.tr),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('common_cancel'.tr,
                  style: context.typography.smRegular.copyWith(color: _muted)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.deleteEvent(event);
              },
              child: Text('common_delete'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: const Color(0xFFEF4444))),
            ),
          ],
        ));
        break;
    }
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onSelected});
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      icon: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(Icons.more_horiz_rounded, size: 19.sp, color: _ink),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'photos',
          child: Row(children: [
            Icon(Icons.photo_library_rounded, size: 18.sp, color: _muted),
            SizedBox(width: 10.w),
            Text('event_photos_title'.tr),
          ]),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_rounded, size: 18.sp, color: _muted),
            SizedBox(width: 10.w),
            Text('common_edit'.tr),
          ]),
        ),
        PopupMenuItem(
          value: 'attendees',
          child: Row(children: [
            Icon(Icons.people_alt_rounded, size: 18.sp, color: _muted),
            SizedBox(width: 10.w),
            Text('event_view_attendees'.tr),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_rounded,
                size: 18.sp, color: const Color(0xFFEF4444)),
            SizedBox(width: 10.w),
            Text('common_delete'.tr,
                style: context.typography.smRegular
                    .copyWith(color: const Color(0xFFEF4444))),
          ]),
        ),
      ],
    );
  }
}
