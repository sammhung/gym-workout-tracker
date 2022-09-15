import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GlobalWorkoutSet extends StatelessWidget {
  final String name;
  final int amount;
  final String measure;
  const GlobalWorkoutSet({
    Key? key,
    required this.amount,
    required this.measure,
    required this.name,
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
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(
                  '$amount ${measure == 'time' ? 'Seconds' : 'Reps'}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
