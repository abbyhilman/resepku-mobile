import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final int reviewId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int userId;
  final String fullName;
  final String email;

  const ReviewModel({
    required this.reviewId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'comment': comment};
  }

  @override
  List<Object?> get props => [
    reviewId,
    rating,
    comment,
    createdAt,
    userId,
    fullName,
    email,
  ];
}
