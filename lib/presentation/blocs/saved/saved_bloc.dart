import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/saved_repository.dart';
import 'saved_event.dart';
import 'saved_state.dart';

class SavedBloc extends Bloc<SavedEvent, SavedState> {
  final SavedRepository _savedRepository;

  SavedBloc(this._savedRepository) : super(SavedInitial()) {
    on<SavedLoad>(_onLoad);
    on<SavedAdd>(_onAdd);
    on<SavedRemove>(_onRemove);
  }

  Future<void> _onLoad(SavedLoad event, Emitter<SavedState> emit) async {
    emit(SavedLoading());
    try {
      final savedRecipes = await _savedRepository.getSavedRecipes();
      emit(SavedLoaded(savedRecipes));
    } catch (e) {
      emit(SavedError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAdd(SavedAdd event, Emitter<SavedState> emit) async {
    try {
      await _savedRepository.saveRecipe(event.recipeId);
      add(SavedLoad()); // Reload the list
    } catch (e) {
      emit(SavedError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRemove(SavedRemove event, Emitter<SavedState> emit) async {
    final currentState = state;
    if (currentState is SavedLoaded) {
      try {
        await _savedRepository.removeSavedRecipe(event.recipeId);
        // Remove from local list
        final updatedList = currentState.savedRecipes
            .where((s) => s.recipe.recipeId != event.recipeId)
            .toList();
        emit(SavedLoaded(updatedList));
      } catch (e) {
        emit(SavedError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}
