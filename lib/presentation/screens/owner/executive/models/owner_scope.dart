/// The level the owner is currently looking at. The ONE switch that drives the
/// whole executive experience: scope = network (all branches) → aggregated
/// view; scope = a single branch → that branch's view. Everything downstream
/// (metrics, insights, dashboard) reads this.
///
/// Modelled as an explicit type — NOT a raw `String? branchId == null` — so that
/// future tiers (a region, a "my branches" subset) slot in without rewriting
/// every null-check into something uglier.
class OwnerScope {
  /// The branch this scope is pinned to. `null` = the whole network.
  final String? branchId;

  /// Display name for the AppBar switcher (branch name, or "All Branches").
  final String? branchName;

  const OwnerScope._(this.branchId, this.branchName);

  /// All branches aggregated — the owner's default landing scope.
  const OwnerScope.network() : this._(null, null);

  /// A single branch.
  const OwnerScope.branch(String id, String name) : this._(id, name);

  bool get isNetwork => branchId == null;

  @override
  bool operator ==(Object other) =>
      other is OwnerScope && other.branchId == branchId;

  @override
  int get hashCode => branchId.hashCode;
}
