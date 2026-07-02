import '../../../index/index.dart';

class HandleKeyboardService {
  static final HandleKeyboardService _instance =
      HandleKeyboardService._internal();

  factory HandleKeyboardService() => _instance;

  HandleKeyboardService._internal();

  /// Map to store focus nodes with unique keys
  final Map<String, FocusNode> _focusNodes = {};

  /// Retrieve a FocusNode using a unique key
  FocusNode getFocusNode(String key) {
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
    }
    return _focusNodes[key]!;
  }

  /// Builds a keyboard configuration with a "Done" button
  KeyboardActionsConfig buildConfig(BuildContext context, List<String> keys) {
    return KeyboardActionsConfig(
      keyboardBarColor: Colors.grey[100],
      nextFocus: true,
      defaultDoneWidget: TextButton(
        onPressed: () => FocusScope.of(context).unfocus(),
        child: AppText( text: "تم",
            textStyle: context.typography.mdMedium
                .copyWith(color: ColorMappingImpl().textLabel)),
      ),
      actions: keys
          .map((key) => KeyboardActionsItem(
                focusNode: getFocusNode(key),
                toolbarButtons: [
                  (node) {
                    return TextButton(
                      onPressed: () => node.unfocus(),
                      child: AppText(
                          text: "تم",
                          textStyle: context.typography.mdMedium
                              .copyWith(color: ColorMappingImpl().textLabel)),
                    );
                  }
                ],
              ))
          .toList(),
    );
  }

  List<String> generateKeys(String screenName, int fieldCount) {
    return List.generate(fieldCount, (index) => '${screenName}_$index');
  }

  /// Dispose all focus nodes
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }
}
