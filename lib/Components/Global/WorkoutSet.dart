import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GlobalWorkoutSet extends StatelessWidget {
  final int amount;
  final String measure;
  final bool isPrView;
  final Exercise exercise;
  final PersonalRecord? pr;
  const GlobalWorkoutSet({
    Key? key,
    required this.amount,
    required this.measure,
    required this.exercise,
    this.isPrView = false,
    this.pr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      width: 80.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name),
                Text(
                  '${isPrView ? pr?.amount ?? '??' : amount} ${measure == 'time' ? 'Seconds' : 'Reps'}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
            if (exercise.weightType == 'weights' && isPrView)
              Text('${pr?.weight ?? '??'} KG'),
          ],
        ),
      ),
    );
  }
}
