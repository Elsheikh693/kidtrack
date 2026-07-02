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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: HomeAppBar(title: 'event_title'.tr),
        floatingActionButton: _GradientFab(onPressed: () => _showCreate(context)),
        body: Obx(() {
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
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 110.h),
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

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    final past = !event.isUpcoming;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover ──
          if (event.coverImage != null)
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Stack(
                children: [
                  AppNetworkImage(
                    url: event.coverImage!,
                    height: 150.h,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: _categoryBadge(color, onDark: true),
                  ),
                  if (past)
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: _pill('event_past'.tr, Colors.black54, Colors.white),
                    ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.coverImage == null) ...[
                      Container(
                        width: 46.w,
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Icon(event.category.icon, color: color, size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: context.typography.mdBold.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (event.coverImage == null) ...[
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                _categoryBadge(color),
                                if (past) ...[
                                  SizedBox(width: 6.w),
                                  _pill('event_past'.tr,
                                      const Color(0xFFF1F5F9), _faint),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    _MenuButton(onSelected: (v) => _onMenu(context, v)),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _infoChip(Icons.calendar_today_rounded,
                        event.formattedDate, color),
                    if (event.timeStr != null && event.timeStr!.isNotEmpty)
                      _infoChip(
                          Icons.access_time_rounded, event.timeStr!, color),
                    if (event.location != null && event.location!.isNotEmpty)
                      _infoChip(
                          Icons.location_on_rounded, event.location!, color),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  SizedBox(height: 12.h),
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
                ],
                SizedBox(height: 12.h),
                Container(height: 1, color: _line),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: _indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.people_alt_rounded,
                          size: 15.sp, color: _indigo),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${event.attendeesCount} ${'event_attendees_count'.tr}',
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 12.5,
                        color: _indigo,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _openAttendees(context),
                      child: Text(
                        'event_view_attendees'.tr,
                        style: context.typography.displaySmBold.copyWith(
                          fontSize: 12.5,
                          color: _muted,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 11.sp, color: _faint),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBadge(Color color, {bool onDark = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.92) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(event.category.icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            event.category.labelKey.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
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
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.more_horiz_rounded, size: 20.sp, color: _muted),
      ),
      itemBuilder: (_) => [
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
