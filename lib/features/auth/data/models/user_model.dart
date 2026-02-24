import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required String username, required String token})
    : super(username: username, token: token);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'token': token};
  }
}
