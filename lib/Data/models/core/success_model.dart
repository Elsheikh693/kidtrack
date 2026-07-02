class SuccessModel {
  final dynamic data;
  final String? message;

  const SuccessModel({this.data, this.message});

  factory SuccessModel.fromJson(Map<String, dynamic> json) {
    return SuccessModel(
      data: json['data'],
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (data != null) 'data': data,
        if (message != null) 'message': message,
      };
}
