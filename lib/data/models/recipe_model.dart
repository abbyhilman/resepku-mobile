import 'package:equatable/equatable.dart';
import 'ingredient_model.dart';
import 'step_model.dart';

class RecipeModel extends Equatable {
  final int recipeId;
  final String title;
  final String description;
  final int prepTimeMin;
  final String? imageUrl;
  final double averageRating;
  final DateTime createdAt;
  final List<IngredientModel>? ingredients;
  final List<StepModel>? steps;

  const RecipeModel({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.prepTimeMin,
    this.imageUrl,
    required this.averageRating,
    required this.createdAt,
    this.ingredients,
    this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      recipeId: json['recipe_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      prepTimeMin: json['prep_time_min'] as int,
      imageUrl: json['image_url'] as String?,
      averageRating: _parseRating(json['average_rating']),
      createdAt: DateTime.parse(json['created_at'] as String),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((e) => StepModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'prep_time_min': prepTimeMin,
      'image_url': imageUrl,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'steps': steps?.map((e) => e.toJson()).toList(),
    };
  }

  /// Convert to database map (for SQLite)
  Map<String, dynamic> toDbMap() {
    return {
      'recipe_id': recipeId,
      'title': title,
      'description': description,
      'prep_time_min': prepTimeMin,
      'image_url': imageUrl,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from database map (from SQLite)
  factory RecipeModel.fromDbMap(Map<String, dynamic> map) {
    return RecipeModel(
      recipeId: map['recipe_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      prepTimeMin: map['prep_time_min'] as int? ?? 0,
      imageUrl: map['image_url'] as String?,
      averageRating: _parseRating(map['average_rating']),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      ingredients: map['ingredients'] != null
          ? (map['ingredients'] as List)
                .map(
                  (e) => IngredientModel.fromDbMap(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      steps: map['steps'] != null
          ? (map['steps'] as List)
                .map((e) => StepModel.fromDbMap(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    recipeId,
    title,
    description,
    prepTimeMin,
    imageUrl,
    averageRating,
    createdAt,
    ingredients,
    steps,
  ];
}
