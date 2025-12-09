import 'package:dio/dio.dart';
import '../models/recipe_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class RecipeRepository {
  final DioClient _dioClient;

  RecipeRepository(this._dioClient);

  /// Get all recipes with optional filters and pagination
  Future<PaginatedResponse<RecipeModel>> getRecipes({
    int? limit,
    int? offset,
    int? prepTimeMin,
    double? averageRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (prepTimeMin != null) queryParams['prep_time_min'] = prepTimeMin;
      if (averageRating != null) queryParams['average_rating'] = averageRating;

      final response = await _dioClient.get(
        ApiEndpoints.recipes,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data['success'] == true) {
        return PaginatedResponse.fromJson(
          response.data,
          (json) => RecipeModel.fromJson(json),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat resep');
      }
    } on DioException catch (e) {
      print('❌ Error in getRecipes: $e');
      if (e.response?.statusCode == 500) {
        throw Exception(
          'Server sedang mengalami masalah. Silakan coba lagi dalam beberapa saat.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );
      }
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat resep');
    } catch (e) {
      print('❌ Unexpected error in getRecipes: $e');
      rethrow;
    }
  }

  /// Get recipe by ID with full details (ingredients, steps)
  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.recipeById(id));

      if (response.data['success'] == true) {
        return RecipeModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Resep tidak ditemukan');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Resep tidak ditemukan');
      } else if (e.response?.statusCode == 500) {
        throw Exception(
          'Server sedang mengalami masalah. Silakan coba lagi dalam beberapa saat.',
        );
      }
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat resep');
    }
  }

  /// Search recipes by keyword (title, description, ingredients)
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.search,
        queryParameters: {'q': query},
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Pencarian gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception(
          'Server sedang mengalami masalah. Silakan coba lagi dalam beberapa saat.',
        );
      }
      throw Exception(e.response?.data['message'] ?? 'Pencarian gagal');
    }
  }
}
