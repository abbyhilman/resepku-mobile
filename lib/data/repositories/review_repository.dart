import '../models/review_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class ReviewRepository {
  final DioClient _dioClient;

  ReviewRepository(this._dioClient);

  Future<List<ReviewModel>> getReviews(int recipeId) async {
    final response = await _dioClient.get(ApiEndpoints.recipeReviews(recipeId));

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Gagal memuat ulasan');
    }
  }

  Future<ReviewModel> createReview({
    required int recipeId,
    required int rating,
    String? comment,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.recipeReviews(recipeId),
      data: {'rating': rating, if (comment != null) 'comment': comment},
    );

    if (response.data['success'] == true) {
      return ReviewModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal membuat ulasan');
    }
  }
}
