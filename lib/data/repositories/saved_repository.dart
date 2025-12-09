import 'package:dio/dio.dart';
import '../models/recipe_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error_handler.dart';

class SavedRecipeModel {
  final int id;
  final DateTime savedAt;
  final RecipeModel recipe;

  SavedRecipeModel({
    required this.id,
    required this.savedAt,
    required this.recipe,
  });

  factory SavedRecipeModel.fromJson(Map<String, dynamic> json) {
    return SavedRecipeModel(
      id: json['id'] as int,
      savedAt: DateTime.parse(json['saved_at'] as String),
      recipe: RecipeModel(
        recipeId: json['recipe_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        prepTimeMin: json['prep_time_min'] as int,
        imageUrl: json['image_url'] as String?,
        averageRating: _parseRating(json['average_rating']),
        createdAt: DateTime.parse(json['created_at'] as String),
      ),
    );
  }

  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }
}

class SavedRepository {
  final DioClient _dioClient;

  SavedRepository(this._dioClient);

  Future<List<SavedRecipeModel>> getSavedRecipes() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.savedRecipes);

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => SavedRecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          ApiErrorHandler.translate(
            response.data['message'] ?? 'Gagal memuat resep tersimpan',
          ),
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    }
  }

  Future<void> saveRecipe(int recipeId) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.savedRecipes,
        data: {'recipe_id': recipeId},
      );

      if (response.data['success'] != true) {
        throw Exception(
          ApiErrorHandler.translate(
            response.data['message'] ?? 'Gagal menyimpan resep',
          ),
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    }
  }

  Future<void> removeSavedRecipe(int recipeId) async {
    try {
      final response = await _dioClient.delete(
        ApiEndpoints.removeSavedRecipe(recipeId),
      );

      if (response.data['success'] != true) {
        throw Exception(
          ApiErrorHandler.translate(
            response.data['message'] ?? 'Gagal menghapus resep dari favorit',
          ),
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    }
  }
}
