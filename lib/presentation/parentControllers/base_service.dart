import '../../index/index_main.dart';

class BaseService<T> {
  final BaseUseCases<T> useCase;

  BaseService(this.useCase);

  Future<void> addData({
    required T item,
    required Map<String, dynamic> Function(T item) toJson,
    required String id,
    required Function(ResponseStatus) voidCallBack,
    bool silent = false,
  }) async {
    if (!silent) Loader.show();

    final result = await useCase.addItem(toJson(item), id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateData({
    required T item,
    required Map<String, dynamic> Function(T item) toJson,
    required String id,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updateItem(toJson(item), id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteData({
    required String id,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteItem(id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getData({
    required Map<String, dynamic> data,
    required Function(List<T?>) voidCallBack,
  }) async {
    final result = await useCase.getItems(data);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
