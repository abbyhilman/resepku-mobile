import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/recipe_repository.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _recipeRepository;
  static const int _pageSize = 5;

  RecipeBloc(this._recipeRepository) : super(RecipeInitial()) {
    on<RecipeLoadAll>(_onLoadAll);
    on<RecipeLoadMore>(_onLoadMore);
    on<RecipeSearch>(_onSearch);
    on<RecipeRefresh>(_onRefresh);
  }

  Future<void> _onLoadAll(
    RecipeLoadAll event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final response = await _recipeRepository.getRecipes(
        limit: event.limit ?? _pageSize,
        offset: event.offset ?? 0,
        prepTimeMin: event.prepTimeMin,
        averageRating: event.averageRating,
      );
      emit(
        RecipeLoaded(
          recipes: response.data,
          hasMore: response.pagination.hasMore,
          total: response.pagination.total,
        ),
      );
    } catch (e) {
      emit(RecipeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    RecipeLoadMore event,
    Emitter<RecipeState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecipeLoaded &&
        !currentState.isLoadingMore &&
        currentState.hasMore) {
      emit(currentState.copyWith(isLoadingMore: true));
      try {
        final response = await _recipeRepository.getRecipes(
          limit: _pageSize,
          offset: currentState.recipes.length,
        );
        emit(
          RecipeLoaded(
            recipes: [...currentState.recipes, ...response.data],
            hasMore: response.pagination.hasMore,
            total: response.pagination.total,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onSearch(RecipeSearch event, Emitter<RecipeState> emit) async {
    if (event.query.isEmpty) {
      add(const RecipeLoadAll());
      return;
    }

    emit(RecipeLoading());
    try {
      final recipes = await _recipeRepository.searchRecipes(event.query);
      emit(RecipeSearchResult(recipes: recipes, query: event.query));
    } catch (e) {
      emit(RecipeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(
    RecipeRefresh event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      final response = await _recipeRepository.getRecipes(
        limit: _pageSize,
        offset: 0,
      );
      emit(
        RecipeLoaded(
          recipes: response.data,
          hasMore: response.pagination.hasMore,
          total: response.pagination.total,
        ),
      );
    } catch (e) {
      emit(RecipeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
