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
    bool allBranches = false,
  }) async {
    final result = await useCase.getItems(data);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(allBranches ? r : _scopeToBranch(r)),
    );
  }

  /// Single choke point for cross-branch scoping. Drops records that belong to
  /// a branch other than the current user's. No-op for unbound users
  /// (owner / super-admin, whose session branch is empty) and for models that
  /// don't implement [BranchScoped], so behaviour is unchanged everywhere a
  /// model hasn't opted in. Pass `allBranches: true` on the rare screen where a
  /// branch-bound user must legitimately see every branch. See [BranchScoped]
  /// for the empty-scope (not-yet-backfilled) policy.
  List<T?> _scopeToBranch(List<T?> items) {
    final session = SessionService();
    return items
        .where((e) =>
            e is! BranchScoped ||
            session.seesAnyBranch((e as BranchScoped).scopeBranches))
        .toList();
  }
}
