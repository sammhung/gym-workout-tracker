import 'package:flutter/material.dart';
import 'package:gym_workout_app/Components/Workout/buttons.dart';
import 'package:gym_workout_app/Components/Workout/stopwatch.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutRestTop extends StatelessWidget {
  final Function onBack;
  final Function onNext;
  final int time;

  const WorkoutRestTop({
    Key? key,
    required this.onBack,
    required this.onNext,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 35.h,
            child: StopWatch(
              title: 'Rest',
              time: time,
              // Doesn't need function
              onAdd: (_) {},
              getTimeSpent: (_) {},
            ),
          ),
          WorkoutButtons(
            onBack: onBack,
            onNext: onNext,
          ),
        ],
      ),
    );
    ;
  }
}
