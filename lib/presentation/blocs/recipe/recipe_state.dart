import 'package:equatable/equatable.dart';
import '../../../data/models/recipe_model.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<RecipeModel> recipes;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;

  const RecipeLoaded({
    required this.recipes,
    this.hasMore = false,
    this.total = 0,
    this.isLoadingMore = false,
  });

  RecipeLoaded copyWith({
    List<RecipeModel>? recipes,
    bool? hasMore,
    int? total,
    bool? isLoadingMore,
  }) {
    return RecipeLoaded(
      recipes: recipes ?? this.recipes,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [recipes, hasMore, total, isLoadingMore];
}

class RecipeSearchResult extends RecipeState {
  final List<RecipeModel> recipes;
  final String query;

  const RecipeSearchResult({required this.recipes, required this.query});

  @override
  List<Object?> get props => [recipes, query];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
