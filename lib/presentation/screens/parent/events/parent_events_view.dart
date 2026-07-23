import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../../manager/media_approval/widgets/full_photo_view.dart';
import 'parent_events_controller.dart';

class ParentEventsView extends StatefulWidget {
  const ParentEventsView({super.key});

  @override
  State<ParentEventsView> createState() => _ParentEventsViewState();
}

class _ParentEventsViewState extends State<ParentEventsView> {
  late final ParentEventsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentEventsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'parent_events_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final upcoming = controller.upcomingEvents;
          final albums = controller.photoAlbums;
          if (upcoming.isEmpty && albums.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'event_no_upcoming'.tr,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              ...upcoming.map((e) => _ParentEventCard(
                    event: e,
                    controller: controller,
                  )),
              if (albums.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                  child: Text(
                    'parent_event_albums_title'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ),
                ...albums.map((e) => _ParentEventAlbumCard(
                      event: e,
                      controller: controller,
                    )),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _ParentEventCard extends StatelessWidget {
  const _ParentEventCard({required this.event, required this.controller});
  final NurseryEventModel event;
  final ParentEventsController controller;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header gradient
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: event.coverImage != null
                    ? DecorationImage(
                        image: appCachedImageProvider(event.coverImage!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          color.withValues(alpha: 0.4),
                          BlendMode.multiply,
                        ),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(event.category.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            event.category.labelKey.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (event.timeStr != null) ...[
                        _chip(Icons.access_time_rounded, event.timeStr!, color),
                        const SizedBox(width: 8),
                      ],
                      if (event.location != null) ...[
                        _chip(Icons.location_on_rounded, event.location!, color),
                        const SizedBox(width: 8),
                      ],
                      if (event.hasPrice)
                        _chip(
                          Icons.payments_rounded,
                          '${event.price!.round()} ${'currency'.tr}',
                          color,
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.people_rounded, size: 14, color: Color(0xFF6366F1)),
                          const SizedBox(width: 4),
                          Text(
                            '${event.attendeesCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Obx(() {
                    final attending = controller.isAttending(event.id);
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDetail(context),
                            icon: const Icon(Icons.info_outline_rounded, size: 16),
                            label: Text('event_details'.tr),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: color,
                              side: BorderSide(color: color),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.toggleAttendance(event),
                            icon: Icon(
                              attending
                                  ? Icons.check_circle_rounded
                                  : Icons.how_to_reg_rounded,
                              size: 16,
                            ),
                            label: Text(attending ? 'event_attending'.tr : 'event_confirm_attendance'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: attending ? const Color(0xFF059669) : color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailSheet(event: event, controller: controller),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event, required this.controller});
  final NurseryEventModel event;
  final ParentEventsController controller;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Cover
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.9), color],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: event.coverImage != null
                    ? DecorationImage(
                        image: appCachedImageProvider(event.coverImage!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          color.withValues(alpha: 0.3),
                          BlendMode.multiply,
                        ),
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.category.labelKey.tr,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta info
                    Row(
                      children: [
                        _metaTile(Icons.calendar_today_rounded, 'event_field_date'.tr, event.formattedDate, color),
                        const SizedBox(width: 12),
                        if (event.timeStr != null)
                          _metaTile(Icons.access_time_rounded, 'event_field_time'.tr, event.timeStr!, color),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 12),
                      _metaTile(Icons.location_on_rounded, 'event_field_location'.tr, event.location!, color),
                    ],
                    if (event.hasPrice) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payments_rounded, color: color, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'event_field_price'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${event.price!.round()} ${'currency'.tr}',
                              style: TextStyle(
                                fontSize: 16,
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Description
                    if (event.description.isNotEmpty) ...[
                      Text(
                        'event_description'.tr,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Approved photos for this child
                    _EventPhotosSection(
                      urls: event
                          .approvedUrlsForChild(controller.activeChildId),
                    ),

                    // Attendees count
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people_rounded, color: color),
                          const SizedBox(width: 10),
                          Text(
                            '${event.attendeesCount} ${'event_confirmed_so_far'.tr}',
                            style: TextStyle(
                              fontSize: 15,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm button
                    Obx(() {
                      final attending = controller.isAttending(event.id);
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => controller.toggleAttendance(event),
                          icon: Icon(
                            attending ? Icons.cancel_rounded : Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            attending ? 'event_cancel_attendance'.tr : 'event_confirm_attendance'.tr,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: attending ? const Color(0xFFDC2626) : const Color(0xFF059669),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: color)),
                  Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Approved photos grid (inside the event detail sheet) ──────────────────────

class _EventPhotosSection extends StatelessWidget {
  const _EventPhotosSection({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'event_photos_title'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: urls.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => FullPhotoView.show(context, urls[i]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: appCachedImageProvider(urls[i]),
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Container(
                  color: const Color(0xFFEDEFF3),
                  child: const Icon(Icons.broken_image_rounded,
                      color: AppColors.grayMedium, size: 20),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Compact past-event album card ─────────────────────────────────────────────

class _ParentEventAlbumCard extends StatelessWidget {
  const _ParentEventAlbumCard({required this.event, required this.controller});

  final NurseryEventModel event;
  final ParentEventsController controller;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;
    final count = event.approvedUrlsForChild(controller.activeChildId).length;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _EventDetailSheet(event: event, controller: controller),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: Row(
          children: [
            _thumb(color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.formattedDate,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.grayMedium),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_rounded, size: 14, color: color),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: context.typography.xsMedium.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(Color color) {
    final url = event.approvedUrlsForChild(controller.activeChildId).isNotEmpty
        ? event.approvedUrlsForChild(controller.activeChildId).first
        : event.coverImage;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: appCachedImageProvider(url),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(event.category.icon, color: color, size: 24),
    );
  }
}
