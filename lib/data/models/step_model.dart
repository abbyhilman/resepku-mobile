import 'package:equatable/equatable.dart';

class StepModel extends Equatable {
  final int? stepId;
  final int? stepNumber;
  final String instruction;

  const StepModel({this.stepId, this.stepNumber, required this.instruction});

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      stepId: json['step_id'] as int?,
      stepNumber: json['step_number'] as int?,
      instruction: json['instruction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'instruction': instruction};
  }

  @override
  List<Object?> get props => [stepId, stepNumber, instruction];
}
