import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Pages/main/workout.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeWorkoutItem extends StatelessWidget {
  final Workout workout;
  const HomeWorkoutItem({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Workout Detail Label
    Widget detail(String detail) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          detail,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
      );
    }

    final List<String> bodyGroups = [];

    for (var group in workout.exerciseGroups) {
      bodyGroups.add(group.name);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => WorkoutDetailsScreen(workout: workout),
          ),
        );
      },
      child: Container(
        height: 40.w,
        width: 40.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Workout Name
              Text(
                workout.workoutName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Workout Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detail(bodyGroups.join(', ')),
                  detail(
                    "${workout.numExercises} Exercises",
                  ),
                  detail(
                    "${workout.numSets} Sets",
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
