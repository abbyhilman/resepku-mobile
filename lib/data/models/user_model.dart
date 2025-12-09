import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int userId;
  final String email;
  final String fullName;
  final DateTime? createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, email, fullName, createdAt];
}
