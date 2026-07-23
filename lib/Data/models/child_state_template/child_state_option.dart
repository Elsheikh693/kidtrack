// A single classification option under a child-state template.
//
// Example tree for the "Eating" state:
//   options = [
//     ChildStateOption(label: 'أكل',      subOptions: ['الكل', 'النص', 'الربع']),
//     ChildStateOption(label: 'لم يأكل',  subOptions: []),
//   ]
//
// Depth is fixed at two levels by product decision: a top-level option and its
// leaf [subOptions]. A top-level option with empty [subOptions] is itself a leaf.
class ChildStateOption {
  final String label;
  final List<String> subOptions;

  const ChildStateOption({
    required this.label,
    this.subOptions = const [],
  });

  factory ChildStateOption.fromJson(Map<String, dynamic> json) {
    return ChildStateOption(
      label: json['label']?.toString() ?? '',
      subOptions: _parseStringList(json['subOptions']),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        if (subOptions.isNotEmpty) 'subOptions': subOptions,
      };

  ChildStateOption copyWith({String? label, List<String>? subOptions}) {
    return ChildStateOption(
      label: label ?? this.label,
      subOptions: subOptions ?? this.subOptions,
    );
  }

  // Firebase RTDB may return a list as a List (sequential keys) or a Map.
  static List<String> _parseStringList(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    return values
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
