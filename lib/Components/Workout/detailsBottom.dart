import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutBottomDetails extends StatelessWidget {
  final List<PersonalRecord> personalRecords;
  final Exercise exercise;
  const WorkoutBottomDetails({
    Key? key,
    required this.personalRecords,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int index =
        personalRecords.indexWhere((element) => element.exercise == exercise);
    final PersonalRecord personalRecord = personalRecords[index];
    print(personalRecord.measure);
    Widget headline(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 17.sp,
        ),
      );
    }

    Widget detail(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17.sp,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "PR",
            ),
            if (personalRecord.exercise.weightType == 'weights')
              detail(
                '${personalRecord.weight ?? '?'}/${personalRecord.amount ?? '?'} R',
              )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Avg",
            ),
            detail('40/8')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Last",
            ),
            detail('42/8')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Body %",
            ),
            detail('79%')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Body Ratio",
            ),
            detail('.79:1')
          ],
        ),
      ],
    );
  }
}
