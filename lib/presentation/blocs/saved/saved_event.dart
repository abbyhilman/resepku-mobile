import 'package:equatable/equatable.dart';

abstract class SavedEvent extends Equatable {
  const SavedEvent();

  @override
  List<Object?> get props => [];
}

class SavedLoad extends SavedEvent {}

class SavedAdd extends SavedEvent {
  final int recipeId;

  const SavedAdd(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class SavedRemove extends SavedEvent {
  final int recipeId;

  const SavedRemove(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}
