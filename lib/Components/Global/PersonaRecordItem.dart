import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PersonalRecordItem extends StatelessWidget {
  final PersonalRecord personalRecord;
  const PersonalRecordItem({
    Key? key,
    required this.personalRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.w,
      width: 40.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(personalRecord.exercise.name),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (personalRecord.exercise.weightType == 'weights')
                  Text(
                    "${personalRecord.weight ?? '??'} KG",
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  ),
                if (personalRecord.exercise.weightType == 'weights')
                  const SizedBox(
                    height: 5,
                  ),
                Text(
                  "${personalRecord.amount ?? '??'} ${personalRecord.measure == 'time' ? 'Seconds' : 'Reps'}",
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
