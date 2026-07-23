import '../../../../../index/index_main.dart';
import 'manage_sheet_scaffold.dart';

/// Bottom sheet to change which fee package(s) the child is subscribed to.
/// Multi-select; at least one package must stay selected because the update
/// PATCH can't clear an omitted key (see [ChildManageMixin.changePackages]).
class ChangePackageSheet extends StatefulWidget {
  const ChangePackageSheet({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  State<ChangePackageSheet> createState() => _ChangePackageSheetState();
}

class _ChangePackageSheetState extends State<ChangePackageSheet> {
  final _selected = <String>{};
  bool _seeded = false;

  void _seed() {
    if (_seeded) return;
    final child = widget.controller.child.value;
    if (child != null) _selected.addAll(child.packageIds);
    _seeded = true;
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  @override
  Widget build(BuildContext context) {
    return ManageSheetScaffold(
      icon: Icons.sell_rounded,
      title: 'child_manage_package_title'.tr,
      child: Obx(() {
        if (widget.controller.isManageLoading.value) {
          return const ManageSheetLoader();
        }
        final child = widget.controller.child.value;
        if (child == null) return const SizedBox.shrink();
        _seed();
        final packages = widget.controller.packagesFor(child.branchId);
        if (packages.isEmpty) {
          return ManageSheetEmpty(text: 'child_change_no_packages'.tr);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...packages.map((p) {
              final id = p.key ?? '';
              return ManageSheetTile(
                label:
                    '${p.name} • ${p.monthlyDue.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                selected: _selected.contains(id),
                onTap: () => _toggle(id),
              );
            }),
            SizedBox(height: 10.h),
            PrimaryTextButton(
              label: AppText(
                text: 'child_change_save'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              appButtonSize: AppButtonSize.large,
              onTap: _selected.isEmpty
                  ? null
                  : () => widget.controller
                      .changePackages(_selected.toList()),
            ),
          ],
        );
      }),
    );
  }
}

/// Loads the lookup options, then opens the change-package sheet.
Future<void> showChangePackageSheet(ChildProfileController controller) {
  controller.loadManageLookups();
  return showManageSheet(ChangePackageSheet(controller: controller));
}
