class LoginResponseModel {
  final String token;
  // final String username;
  final String refreshToken;

  LoginResponseModel({required this.token, required this.refreshToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}
