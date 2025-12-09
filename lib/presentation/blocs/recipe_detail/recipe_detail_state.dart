import 'package:equatable/equatable.dart';
import '../../../data/models/recipe_model.dart';
import '../../../data/models/review_model.dart';

abstract class RecipeDetailState extends Equatable {
  const RecipeDetailState();

  @override
  List<Object?> get props => [];
}

class RecipeDetailInitial extends RecipeDetailState {}

class RecipeDetailLoading extends RecipeDetailState {}

class RecipeDetailLoaded extends RecipeDetailState {
  final RecipeModel recipe;
  final List<ReviewModel> reviews;
  final bool isSaved;

  const RecipeDetailLoaded({
    required this.recipe,
    this.reviews = const [],
    this.isSaved = false,
  });

  RecipeDetailLoaded copyWith({
    RecipeModel? recipe,
    List<ReviewModel>? reviews,
    bool? isSaved,
  }) {
    return RecipeDetailLoaded(
      recipe: recipe ?? this.recipe,
      reviews: reviews ?? this.reviews,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [recipe, reviews, isSaved];
}

class RecipeDetailError extends RecipeDetailState {
  final String message;

  const RecipeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
