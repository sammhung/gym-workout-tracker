import 'package:gym_workout_app/Classes/exercise.dart';

class PersonalRecord {
  final Exercise exercise;
  List<Map<String, dynamic>>? historyWeight;
  List<Map<String, dynamic>>? historyAmount;
  double? weight;
  String? measure;
  double? amount;

  PersonalRecord({
    required this.amount,
    required this.exercise,
    required this.measure,
    required this.weight,
    required this.historyAmount,
    required this.historyWeight,
  });
}
