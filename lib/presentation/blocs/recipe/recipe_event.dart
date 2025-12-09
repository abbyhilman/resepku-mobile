import 'package:equatable/equatable.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class RecipeLoadAll extends RecipeEvent {
  final int? limit;
  final int? offset;
  final int? prepTimeMin;
  final double? averageRating;

  const RecipeLoadAll({
    this.limit,
    this.offset,
    this.prepTimeMin,
    this.averageRating,
  });

  @override
  List<Object?> get props => [limit, offset, prepTimeMin, averageRating];
}

class RecipeLoadMore extends RecipeEvent {}

class RecipeSearch extends RecipeEvent {
  final String query;

  const RecipeSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class RecipeRefresh extends RecipeEvent {}
