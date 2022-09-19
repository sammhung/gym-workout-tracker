import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';

class WorkoutGroup {
  String? id;
  final String groupType;
  final List<Exercise> exercises;
  final List<String> measure;
  final int rest;
  final int sets;
  List<PersonalRecord> personalRecords;
  // Amount could be time or reps, depending on the measure
  final List<int> amount;

  WorkoutGroup({
    required this.id,
    required this.amount,
    required this.rest,
    required this.exercises,
    required this.groupType,
    required this.measure,
    required this.sets,
    required this.personalRecords,
  });
}
