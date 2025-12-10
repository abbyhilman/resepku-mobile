import 'package:dio/dio.dart';
import '../models/recipe_model.dart';
import '../models/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/network/connectivity_helper.dart';
import '../../core/database/database_helper.dart';

class RecipeRepository {
  final DioClient _dioClient;
  final DatabaseHelper _dbHelper;
  final ConnectivityHelper _connectivityHelper;

  RecipeRepository(this._dioClient, this._dbHelper, this._connectivityHelper);

  /// Get all recipes with optional filters and pagination
  Future<PaginatedResponse<RecipeModel>> getRecipes({
    int? limit,
    int? offset,
    int? prepTimeMin,
    double? averageRating,
  }) async {
    final hasConnection = await _connectivityHelper.hasConnection();

    // Try to get from API if connected
    if (hasConnection) {
      try {
        final queryParams = <String, dynamic>{};

        if (limit != null) queryParams['limit'] = limit;
        if (offset != null) queryParams['offset'] = offset;
        if (prepTimeMin != null) queryParams['prep_time_min'] = prepTimeMin;
        if (averageRating != null)
          queryParams['average_rating'] = averageRating;

        final response = await _dioClient.get(
          ApiEndpoints.recipes,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        );

        if (response.data['success'] == true) {
          final paginatedResponse = PaginatedResponse.fromJson(
            response.data,
            (json) => RecipeModel.fromJson(json),
          );

          // Cache recipes to local database
          if (paginatedResponse.data.isNotEmpty) {
            final recipeMaps = paginatedResponse.data
                .map((r) => r.toDbMap())
                .toList();
            await _dbHelper.cacheRecipes(recipeMaps);
          }

          return paginatedResponse;
        } else {
          throw Exception(
            ApiErrorHandler.translate(
              response.data['message'] ?? 'Gagal memuat resep',
            ),
          );
        }
      } on DioException catch (e) {
        // If API fails, try to get from cache
        return _getRecipesFromCache(limit: limit, offset: offset);
      } catch (e) {
        return _getRecipesFromCache(limit: limit, offset: offset);
      }
    } else {
      // Offline - get from cache
      return _getRecipesFromCache(limit: limit, offset: offset);
    }
  }

  /// Get recipes from local cache
  Future<PaginatedResponse<RecipeModel>> _getRecipesFromCache({
    int? limit,
    int? offset,
  }) async {
    try {
      final cachedMaps = await _dbHelper.getCachedRecipes(
        limit: limit,
        offset: offset,
      );

      final recipes = cachedMaps.map((m) => RecipeModel.fromDbMap(m)).toList();

      return PaginatedResponse<RecipeModel>(
        success: true,
        data: recipes,
        pagination: PaginationInfo(
          total: recipes.length,
          limit: limit ?? recipes.length,
          offset: offset ?? 0,
          hasMore: false, // Can't know if there's more in offline mode
        ),
      );
    } catch (e) {
      return PaginatedResponse<RecipeModel>(
        success: true,
        data: [],
        pagination: PaginationInfo(
          total: 0,
          limit: limit ?? 0,
          offset: offset ?? 0,
          hasMore: false,
        ),
      );
    }
  }

  /// Get recipe by ID with full details (ingredients, steps)
  Future<RecipeModel> getRecipeById(int id) async {
    final hasConnection = await _connectivityHelper.hasConnection();

    if (hasConnection) {
      try {
        final response = await _dioClient.get(ApiEndpoints.recipeById(id));

        if (response.data['success'] == true) {
          final recipe = RecipeModel.fromJson(response.data['data']);

          // Cache the full recipe with ingredients and steps
          final ingredientMaps =
              recipe.ingredients
                  ?.map(
                    (i) => {
                      'name': i.name,
                      'quantity': i.quantity,
                      'unit': i.unit,
                    },
                  )
                  .toList() ??
              [];
          final stepMaps =
              recipe.steps
                  ?.map(
                    (s) => {
                      'step_number': s.stepNumber,
                      'instruction': s.instruction,
                    },
                  )
                  .toList() ??
              [];

          await _dbHelper.cacheRecipeDetail(
            recipe.toDbMap(),
            ingredientMaps,
            stepMaps,
          );

          return recipe;
        } else {
          throw Exception(
            ApiErrorHandler.translate(
              response.data['message'] ?? 'Resep tidak ditemukan',
            ),
          );
        }
      } on DioException {
        // Try cache on network error
        return _getRecipeByIdFromCache(id);
      }
    } else {
      return _getRecipeByIdFromCache(id);
    }
  }

  /// Get recipe from cache
  Future<RecipeModel> _getRecipeByIdFromCache(int id) async {
    final cached = await _dbHelper.getCachedRecipeById(id);
    if (cached != null) {
      return RecipeModel.fromDbMap(cached);
    }
    throw Exception('Resep tidak tersedia dalam mode offline');
  }

  /// Search recipes by keyword (title, description, ingredients)
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final hasConnection = await _connectivityHelper.hasConnection();

    if (hasConnection) {
      try {
        final response = await _dioClient.get(
          ApiEndpoints.search,
          queryParameters: {'q': query},
        );

        if (response.data['success'] == true) {
          final recipes = (response.data['data'] as List)
              .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
              .toList();

          // Cache search results
          if (recipes.isNotEmpty) {
            final recipeMaps = recipes.map((r) => r.toDbMap()).toList();
            await _dbHelper.cacheRecipes(recipeMaps);
          }

          return recipes;
        } else {
          throw Exception(
            ApiErrorHandler.translate(
              response.data['message'] ?? 'Pencarian gagal',
            ),
          );
        }
      } on DioException catch (e) {
        throw Exception(ApiErrorHandler.handleDioError(e));
      }
    } else {
      // Offline search - basic local search by title
      final cached = await _dbHelper.getCachedRecipes();
      return cached
          .map((m) => RecipeModel.fromDbMap(m))
          .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
