import 'package:gym_workout_app/Classes/exercise.dart';

class ExerciseGroup {
  final String name;
  final List<Exercise> exercises;

  ExerciseGroup({
    required this.exercises,
    required this.name,
  });
}
