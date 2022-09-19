import 'package:gym_workout_app/Classes/exercise.dart';

class PersonalRecord {
  final Exercise exercise;
  double? weight;
  String? measure;
  double? amount;

  PersonalRecord({
    required this.amount,
    required this.exercise,
    required this.measure,
    required this.weight,
  });
}
