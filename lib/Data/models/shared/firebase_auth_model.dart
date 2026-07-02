class FirebaseAuthModel {
  final String email;
  final String password;

  const FirebaseAuthModel({required this.email, required this.password});

  factory FirebaseAuthModel.fromJson(Map<String, dynamic> json) {
    return FirebaseAuthModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
