/// Marker interface for records that belong to one or more branches.
///
/// Any model that implements this is automatically scoped to the current
/// user's branch by [BaseService.getData] (the single choke point for every
/// list read): a branch-bound user (teacher, supervisor, reception, branch
/// manager) only receives records whose [scopeBranches] include their branch,
/// while an unbound user (owner / super-admin, whose session branch is empty)
/// receives everything.
///
/// [scopeBranches] returns the branch ids this record belongs to:
///   * single-branch model → `[branchId]` (or `[]` when unset)
///   * multi-branch model  → `branchIds`
///
/// An EMPTY list means "unscoped / all-branches" and stays visible to everyone.
/// This is deliberate (phased policy): legacy / not-yet-backfilled records are
/// never hidden while the `branchId` backfill is still running. Once coverage
/// is complete the empty-scope allowance can be tightened.
///
/// See [SessionService.seesAnyBranch] for the matching logic.
abstract class BranchScoped {
  List<String> get scopeBranches;
}
