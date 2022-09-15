import 'package:gym_workout_app/Classes/exerciseGroup.dart';

class Exercise {
  final String name;
  final String category;
  final String id;
  final String type;
  final String weightType;

  const Exercise({
    required this.id,
    required this.category,
    required this.name,
    required this.type,
    required this.weightType,
  });
}
