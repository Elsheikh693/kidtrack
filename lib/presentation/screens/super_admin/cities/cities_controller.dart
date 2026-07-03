import '../../../../index/index_main.dart';
import 'widgets/city_sheet.dart';

class CitiesController extends GetxController {
  final _service = Get.find<CityParentService>();

  final RxList<CityModel> items = <CityModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<CityModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(CityModel item) => _openSheet(item);

  void _openSheet(CityModel? item) {
    Get.bottomSheet(
      CitySheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(CityModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('cities_deleted'.tr);
          loadData();
        } else {
          Loader.showError('cities_error'.tr);
        }
      },
    );
  }
}
