import 'package:equatable/equatable.dart';

abstract class RecipeDetailEvent extends Equatable {
  const RecipeDetailEvent();

  @override
  List<Object?> get props => [];
}

class RecipeDetailLoad extends RecipeDetailEvent {
  final int recipeId;

  const RecipeDetailLoad(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class RecipeDetailToggleSave extends RecipeDetailEvent {
  final int recipeId;
  final bool isSaved;

  const RecipeDetailToggleSave({required this.recipeId, required this.isSaved});

  @override
  List<Object?> get props => [recipeId, isSaved];
}
