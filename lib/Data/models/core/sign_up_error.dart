class SignUpErrorModel {
  final Map<String, List<String>> errors;

  const SignUpErrorModel({required this.errors});

  factory SignUpErrorModel.fromJson(Map<String, dynamic> json) {
    return SignUpErrorModel(
      errors: (json['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {'errors': errors};

  @override
  String toString() {
    return errors.entries
        .map((e) => '${e.key}: ${e.value.join(", ")}')
        .join('\n');
  }
}
