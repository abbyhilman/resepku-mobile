import 'package:equatable/equatable.dart';
import '../../../data/repositories/saved_repository.dart';

abstract class SavedState extends Equatable {
  const SavedState();

  @override
  List<Object?> get props => [];
}

class SavedInitial extends SavedState {}

class SavedLoading extends SavedState {}

class SavedLoaded extends SavedState {
  final List<SavedRecipeModel> savedRecipes;

  const SavedLoaded(this.savedRecipes);

  @override
  List<Object?> get props => [savedRecipes];
}

class SavedError extends SavedState {
  final String message;

  const SavedError(this.message);

  @override
  List<Object?> get props => [message];
}
