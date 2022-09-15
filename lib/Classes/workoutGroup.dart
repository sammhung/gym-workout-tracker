import 'package:gym_workout_app/Classes/exercise.dart';

class WorkoutGroup {
  final String groupType;
  final List<Exercise> exercises;
  final List<String> measure;
  final int rest;
  final int sets;
  // Amount could be time or reps, depending on the measure
  final List<int> amount;

  WorkoutGroup({
    required this.amount,
    required this.rest,
    required this.exercises,
    required this.groupType,
    required this.measure,
    required this.sets,
  });
}
