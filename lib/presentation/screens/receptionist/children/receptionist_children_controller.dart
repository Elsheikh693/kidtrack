import '../../../../index/index_main.dart';

/// Dedicated type so the receptionist Children tab gets its own controller
/// instance (separate fenix singleton) — prevents shift/status filter state
/// from leaking into the shared owner [ChildListController] screen.
class ReceptionistChildrenController extends ChildListController {}
