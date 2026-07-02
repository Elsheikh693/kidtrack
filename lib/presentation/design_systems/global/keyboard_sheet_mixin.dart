import '../../../index/index.dart';

/// Mixin for bottom-sheet [State] classes that contain text fields.
///
/// Usage:
/// ```dart
/// class _MySheetState extends State<MySheet> with KeyboardSheetMixin {
///   late final FocusNode _nameFocus;
///
///   @override
///   void initState() {
///     super.initState();
///     _nameFocus = kbNode();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return wrapWithKeyboard(
///       context: context,
///       child: SingleChildScrollView(...),
///     );
///   }
/// }
/// ```
mixin KeyboardSheetMixin<T extends StatefulWidget> on State<T> {
  final List<FocusNode> _kbNodes = [];

  /// Creates a [FocusNode] tracked by the mixin. Call once per text field in [initState].
  FocusNode kbNode() {
    final node = FocusNode();
    _kbNodes.add(node);
    return node;
  }

  /// Wraps [child] with [KeyboardActions] so a "تم" toolbar appears above the keyboard.
  /// Replace the outer `Padding(viewInsets.bottom, ...)` with this.
  /// Focus nodes are optional – the [defaultDoneWidget] handles any focused text field
  /// even when no explicit [focusNode] is passed to the [TextField].
  Widget wrapWithKeyboard({
    required BuildContext context,
    required Widget child,
  }) {
    final done = TextButton(
      onPressed: () => FocusScope.of(context).unfocus(),
      child: Text(
        'تم',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
    return KeyboardActions(
      config: KeyboardActionsConfig(
        keyboardBarColor: Colors.grey[100],
        nextFocus: true,
        defaultDoneWidget: done,
        actions: _kbNodes
            .map(
              (node) => KeyboardActionsItem(
                focusNode: node,
                toolbarButtons: [
                  (n) => TextButton(
                        onPressed: () => n.unfocus(),
                        child: Text(
                          'تم',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                ],
              ),
            )
            .toList(),
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    for (final n in _kbNodes) {
      n.dispose();
    }
    super.dispose();
  }
}
