import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/recipe_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import 'recipe_detail_event.dart';
import 'recipe_detail_state.dart';

class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final RecipeRepository _recipeRepository;
  final ReviewRepository _reviewRepository;
  final SavedRepository _savedRepository;

  RecipeDetailBloc(
    this._recipeRepository,
    this._reviewRepository,
    this._savedRepository,
  ) : super(RecipeDetailInitial()) {
    on<RecipeDetailLoad>(_onLoad);
    on<RecipeDetailToggleSave>(_onToggleSave);
  }

  Future<void> _onLoad(
    RecipeDetailLoad event,
    Emitter<RecipeDetailState> emit,
  ) async {
    emit(RecipeDetailLoading());
    try {
      final recipe = await _recipeRepository.getRecipeById(event.recipeId);
      final reviews = await _reviewRepository.getReviews(event.recipeId);

      // Check if saved (only if user is logged in)
      bool isSaved = false;
      try {
        final savedRecipes = await _savedRepository.getSavedRecipes();
        isSaved = savedRecipes.any((s) => s.recipe.recipeId == event.recipeId);
      } catch (_) {
        // User not logged in or error, ignore
      }

      emit(
        RecipeDetailLoaded(recipe: recipe, reviews: reviews, isSaved: isSaved),
      );
    } catch (e) {
      emit(RecipeDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onToggleSave(
    RecipeDetailToggleSave event,
    Emitter<RecipeDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecipeDetailLoaded) {
      try {
        if (event.isSaved) {
          await _savedRepository.removeSavedRecipe(event.recipeId);
        } else {
          await _savedRepository.saveRecipe(event.recipeId);
        }
        emit(currentState.copyWith(isSaved: !event.isSaved));
      } catch (e) {
        // Revert on error - already in original state
      }
    }
  }
}
