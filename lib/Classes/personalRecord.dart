import 'package:gym_workout_app/Classes/exercise.dart';

class PersonalRecord {
  final Exercise exercise;
  final double? weight;
  final String? measure;
  final int? amount;

  PersonalRecord({
    required this.amount,
    required this.exercise,
    required this.measure,
    required this.weight,
  });
}
