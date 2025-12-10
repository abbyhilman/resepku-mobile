import 'package:dio/dio.dart';
import '../models/recipe_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/network/connectivity_helper.dart';
import '../../core/database/database_helper.dart';

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

  factory SavedRecipeModel.fromDbMap(Map<String, dynamic> map) {
    return SavedRecipeModel(
      id: map['id'] as int,
      savedAt: DateTime.parse(map['saved_at'] as String),
      recipe: RecipeModel(
        recipeId: map['recipe_id'] as int,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        prepTimeMin: map['prep_time_min'] as int? ?? 0,
        imageUrl: map['image_url'] as String?,
        averageRating: _parseRating(map['average_rating']),
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'recipe_id': recipe.recipeId,
      'title': recipe.title,
      'description': recipe.description,
      'prep_time_min': recipe.prepTimeMin,
      'image_url': recipe.imageUrl,
      'average_rating': recipe.averageRating,
      'created_at': recipe.createdAt.toIso8601String(),
      'saved_at': savedAt.toIso8601String(),
    };
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
  final DatabaseHelper _dbHelper;
  final ConnectivityHelper _connectivityHelper;

  SavedRepository(this._dioClient, this._dbHelper, this._connectivityHelper);

  Future<List<SavedRecipeModel>> getSavedRecipes() async {
    final hasConnection = await _connectivityHelper.hasConnection();

    if (hasConnection) {
      try {
        final response = await _dioClient.get(ApiEndpoints.savedRecipes);

        if (response.data['success'] == true) {
          final savedRecipes = (response.data['data'] as List)
              .map((e) => SavedRecipeModel.fromJson(e as Map<String, dynamic>))
              .toList();

          // Cache saved recipes
          if (savedRecipes.isNotEmpty) {
            final maps = savedRecipes.map((s) => s.toDbMap()).toList();
            await _dbHelper.cacheSavedRecipes(maps);
          }

          return savedRecipes;
        } else {
          throw Exception(
            ApiErrorHandler.translate(
              response.data['message'] ?? 'Gagal memuat resep tersimpan',
            ),
          );
        }
      } on DioException {
        // Try cache on network error
        return _getSavedRecipesFromCache();
      }
    } else {
      // Offline - get from cache
      return _getSavedRecipesFromCache();
    }
  }

  Future<List<SavedRecipeModel>> _getSavedRecipesFromCache() async {
    try {
      final cachedMaps = await _dbHelper.getCachedSavedRecipes();
      return cachedMaps.map((m) => SavedRecipeModel.fromDbMap(m)).toList();
    } catch (e) {
      print('❌ Error getting saved recipes from cache: $e');
      return [];
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
