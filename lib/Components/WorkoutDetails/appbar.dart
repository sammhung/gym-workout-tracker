import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';
import 'package:gym_workout_app/Pages/main/viewWorkout.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutDetailsAppbar extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailsAppbar({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button and title
        const GlobalBackButton(),
        const Spacer(),
        Text(
          workout.workoutName,
          style: Theme.of(context).textTheme.headline1,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ViewWorkoutScreen(
                  workout: workout,
                ),
              ),
            );
          },
          child: Icon(
            Icons.edit_outlined,
            size: 22.sp,
          ),
        ),
      ],
    );
  }
}
