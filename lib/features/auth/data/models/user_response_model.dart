// lib/features/auth/data/models/user_response_model.dart

class UserResponseModel {
  final String customerId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;

  UserResponseModel({
    required this.customerId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      customerId: json['customerId']?['id'] ?? json['id']?['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
    );
  }
}
