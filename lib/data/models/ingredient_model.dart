import 'package:equatable/equatable.dart';

class IngredientModel extends Equatable {
  final int? ingredientId;
  final String name;
  final String quantity;
  final String unit;

  const IngredientModel({
    this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      ingredientId: json['ingredient_id'] as int?,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit};
  }

  factory IngredientModel.fromDbMap(Map<String, dynamic> map) {
    return IngredientModel(
      ingredientId: map['id'] as int?,
      name: map['name'] as String? ?? '',
      quantity: map['quantity'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [ingredientId, name, quantity, unit];
}
