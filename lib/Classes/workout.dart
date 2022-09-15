import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';

class Workout {
  final String workoutName;
  final int numExercises;
  final int numSets;
  final double restTime;
  // Body Groups worked
  final List<ExerciseGroup> exerciseGroups;
  final List<PersonalRecord> personalRecords;
  List<WorkoutGroup> workoutGroups;

  Workout({
    required this.personalRecords,
    required this.numExercises,
    required this.restTime,
    required this.numSets,
    required this.workoutName,
    required this.exerciseGroups,
    required this.workoutGroups,
  });
}
