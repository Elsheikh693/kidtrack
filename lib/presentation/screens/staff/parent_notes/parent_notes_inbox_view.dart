import '../../../../index/index_main.dart';
import 'widgets/parent_note_card.dart';
import 'widgets/parent_notes_date_bar.dart';
import 'widgets/parent_notes_day_header.dart';
import 'widgets/parent_notes_empty.dart';

/// Staff inbox of guardian-authored session notes, with a date filter. Rendered
/// as a teacher tab and pushed from the manager "More" grid.
class ParentNotesInboxView extends StatefulWidget {
  const ParentNotesInboxView({super.key});

  @override
  State<ParentNotesInboxView> createState() => _ParentNotesInboxViewState();
}

class _ParentNotesInboxViewState extends State<ParentNotesInboxView> {
  late final ParentNotesInboxController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentNotesInboxController>();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'parent_notes_inbox_title'.tr,
        onBack: canPop ? () => Get.back() : null,
      ),
      body: Column(
        children: [
          ParentNotesDateBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final days = controller.days;
              if (days.isEmpty) return const ParentNotesEmpty();

              return RefreshIndicator(
                onRefresh: controller.reload,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final day = days[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentNotesDayHeader(
                          date: day.date,
                          count: day.notes.length,
                        ),
                        for (final note in day.notes)
                          ParentNoteCard(
                            note: note,
                            classroomLabel: controller.classroomName(note),
                          ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
