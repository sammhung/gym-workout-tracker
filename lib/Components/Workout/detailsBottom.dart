import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:gym_workout_app/Providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutBottomDetails extends StatelessWidget {
  final List<PersonalRecord> personalRecords;
  final Exercise exercise;
  final int setIndex;
  const WorkoutBottomDetails({
    Key? key,
    required this.personalRecords,
    required this.exercise,
    required this.setIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);

    final int index =
        personalRecords.indexWhere((element) => element.exercise == exercise);
    final PersonalRecord personalRecord = personalRecords[index];
    final String? measure = personalRecord.measure;
    final String weightType = exercise.weightType;
    final double? weight = personalRecord.weight;
    final double? amount = personalRecord.amount;

    List<double> sevenDaysAmount = [];
    List<double> sevenDayWeights = [];

    for (int i = 0; i < personalRecord.historyAmount!.length; i++) {
      DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));
      Map<String, dynamic> amountItem = personalRecord.historyAmount![i];
      if (amountItem['date'].isAfter(currentDate)) {
        sevenDaysAmount.add(amountItem['amount']);
        if (personalRecord.historyWeight!.isNotEmpty) {
          sevenDayWeights.add(personalRecord.historyWeight![i]['weight']);
        }
      }
    }

    // Average amount for past 7 days
    double sevenDayAverageAmount = 0;
    double lastAmount = 0;
    if (personalRecord.historyAmount!.isNotEmpty) {
      sevenDayAverageAmount =
          sevenDaysAmount.reduce((a, b) => a + b) / sevenDaysAmount.length;
      if (personalRecord.historyAmount!.length > setIndex + 1) {
        lastAmount = personalRecord.historyAmount![
            personalRecord.historyAmount!.length - 1 - setIndex]['amount'];
      }
    }

    // Average weight for past 7 days
    double sevenDayAverageWeight = 0;
    double lastWeight = 0;
    if (personalRecord.historyWeight!.isNotEmpty) {
      sevenDayAverageWeight =
          sevenDayWeights.reduce((a, b) => a + b) / sevenDayWeights.length;
      if (personalRecord.historyWeight!.length > setIndex + 1) {
        lastWeight = personalRecord.historyWeight![
            personalRecord.historyWeight!.length - 1 - setIndex]['weight'];
      }
    }
    double bodyRatio = double.parse(
        (sevenDayAverageWeight / auth.userWeight).toStringAsFixed(2));

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
            if (weightType == 'weights' && measure == 'reps')
              detail(
                '${weight?.round() ?? '?'}/${amount?.round() ?? '?'} R',
              ),
            if (weightType == 'weights' && measure == 'time')
              detail(
                '${weight?.round() ?? '?'}/${amount?.round() ?? '?'} S',
              ),
            if (weightType == 'body weight' && measure == 'reps')
              detail(
                '${amount?.round() ?? '?'} Reps',
              ),
            if (weightType == 'body weight' && measure == 'time')
              detail(
                '${amount?.round() ?? '?'} Sec',
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Past 7 Days Avg",
            ),
            if (weightType == 'weights' && measure == 'reps')
              detail(
                '${sevenDayAverageWeight == 0 ? '?' : sevenDayAverageWeight.round()}/${sevenDayAverageAmount == 0 ? '?' : sevenDayAverageAmount.round()} R',
              ),
            if (weightType == 'weights' && measure == 'time')
              detail(
                '${sevenDayAverageWeight == 0 ? '?' : sevenDayAverageWeight.round()}/${sevenDayAverageAmount == 0 ? '?' : sevenDayAverageAmount.round()} S',
              ),
            if (weightType == 'body weight' && measure == 'reps')
              detail(
                '${sevenDayAverageAmount == 0 ? '?' : sevenDayAverageAmount.round()} Reps',
              ),
            if (weightType == 'body weight' && measure == 'time')
              detail(
                '${sevenDayAverageAmount == 0 ? '?' : sevenDayAverageAmount.round()} Sec',
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(
              "Last",
            ),
            if (weightType == 'weights' && measure == 'reps')
              detail(
                '${lastWeight == 0 ? '?' : lastWeight.round()}/${lastAmount == 0 ? '?' : lastAmount.round()} R',
              ),
            if (weightType == 'weights' && measure == 'time')
              detail(
                '${lastWeight == 0 ? '?' : lastWeight.round()}/${lastAmount == 0 ? '?' : lastAmount.round()} S',
              ),
            if (weightType == 'body weight' && measure == 'reps')
              detail(
                '${lastAmount == 0 ? '?' : lastAmount.round()} Reps',
              ),
            if (weightType == 'body weight' && measure == 'time')
              detail(
                '${lastAmount == 0 ? '?' : lastAmount.round()} Sec',
              ),
          ],
        ),
        if (weightType == 'weights')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headline(
                "Body %",
              ),
              detail('${(bodyRatio * 100).round()}%')
            ],
          ),
        if (weightType == 'weights')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headline(
                "Body Ratio",
              ),
              detail('$bodyRatio:1')
            ],
          ),
      ],
    );
  }
}
