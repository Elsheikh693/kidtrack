class ErrorModel {
  final String? message;

  const ErrorModel({this.message});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final errors = json['errors'];
    String? msg;

    if (errors is Map<String, dynamic>) {
      msg = errors.values
          .expand((v) => v is List ? v : [v])
          .join(', ');
    } else if (errors is String) {
      msg = errors;
    } else {
      msg = json['message']?.toString();
    }

    return ErrorModel(message: msg);
  }

  Map<String, dynamic> toJson() => {
        if (message != null) 'message': message,
      };
}
