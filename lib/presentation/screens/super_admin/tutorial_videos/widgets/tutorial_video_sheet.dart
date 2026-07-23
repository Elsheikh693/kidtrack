import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../../../index/index_main.dart';
import 'tutorial_roles.dart';
import 'role_selector.dart';
import 'media_pick_tile.dart';
import 'sheet_field.dart';

/// Add / edit form for a tutorial video. Collects inputs + picked media, then
/// hands everything to [SaTutorialVideosController.saveVideo] which uploads and
/// persists.
class TutorialVideoSheet extends StatefulWidget {
  final TutorialVideoModel? existing;
  const TutorialVideoSheet({super.key, this.existing});

  @override
  State<TutorialVideoSheet> createState() => _TutorialVideoSheetState();
}

class _TutorialVideoSheetState extends State<TutorialVideoSheet> {
  late final SaTutorialVideosController controller;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();

  final Set<String> _roles = {};
  File? _videoFile;
  File? _thumbFile;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SaTutorialVideosController>();
    final e = widget.existing;
    _titleCtrl.text = e?.title ?? '';
    _descCtrl.text = e?.description ?? '';
    _orderCtrl.text = (e?.order ?? controller.items.length).toString();
    _roles.addAll(e?.audience ?? const []);
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (x != null) setState(() => _videoFile = File(x.path));
  }

  Future<void> _pickThumb() async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file != null) setState(() => _thumbFile = file);
    });
  }

  void _toggleRole(String name) {
    setState(() =>
        _roles.contains(name) ? _roles.remove(name) : _roles.add(name));
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Loader.showError('tutorial_title_required'.tr);
      return;
    }
    controller.saveVideo(
      existing: widget.existing,
      title: title,
      description: _descCtrl.text,
      order: int.tryParse(_orderCtrl.text.trim()) ?? 0,
      audience: _roles.toList(),
      isActive: _isActive,
      videoFile: _videoFile,
      thumbFile: _thumbFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              AppText(
                text: isNew
                    ? 'tutorial_admin_add'.tr
                    : 'tutorial_admin_edit'.tr,
                textStyle: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 18.h),
              SheetField(
                label: 'tutorial_field_title'.tr,
                controller: _titleCtrl,
                hint: 'tutorial_field_title_hint'.tr,
              ),
              SizedBox(height: 14.h),
              SheetField(
                label: 'tutorial_field_desc'.tr,
                controller: _descCtrl,
                hint: 'tutorial_field_desc_hint'.tr,
                maxLines: 3,
              ),
              SizedBox(height: 14.h),
              SheetField(
                label: 'tutorial_field_order'.tr,
                controller: _orderCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 18.h),
              MediaPickTile(
                label: 'tutorial_pick_video'.tr,
                icon: Icons.video_library_rounded,
                pickedName: _videoFile != null
                    ? _videoFile!.path.split('/').last
                    : (widget.existing?.videoUrl.isNotEmpty ?? false
                        ? 'tutorial_current_video'.tr
                        : null),
                onTap: _pickVideo,
              ),
              SizedBox(height: 10.h),
              MediaPickTile(
                label: 'tutorial_pick_thumb'.tr,
                icon: Icons.image_rounded,
                pickedName: _thumbFile != null
                    ? _thumbFile!.path.split('/').last
                    : (widget.existing?.hasThumbnail ?? false
                        ? 'tutorial_current_thumb'.tr
                        : null),
                onTap: _pickThumb,
              ),
              SizedBox(height: 18.h),
              AppText(
                text: 'tutorial_field_audience'.tr,
                textStyle: context.typography.xsMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 10.h),
              RoleSelector(
                roles: kTutorialRoles,
                selected: _roles,
                onToggle: _toggleRole,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  AppText(
                    text: 'tutorial_field_active'.tr,
                    textStyle: context.typography.smMedium
                        .copyWith(color: AppColors.textDefault),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: AppText(
                    text: isNew
                        ? 'tutorial_admin_save'.tr
                        : 'tutorial_admin_update'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
