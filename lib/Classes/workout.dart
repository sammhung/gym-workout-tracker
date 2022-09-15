import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';

class Workout {
  final String workoutName;
  final int numExercises;
  final int numSets;
  final double restTime;
  // Body Groups worked
  final List<ExerciseGroup> exerciseGroups;
  final List<WorkoutGroup> workoutGroups;

  Workout({
    required this.numExercises,
    required this.restTime,
    required this.numSets,
    required this.workoutName,
    required this.exerciseGroups,
    required this.workoutGroups,
  });
}
