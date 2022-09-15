import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Global/WorkoutSet.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GlobalWorkoutGroup extends StatelessWidget {
  final WorkoutGroup workoutGroup;
  final int index;
  Function(WorkoutGroup) deleteGroup;
  Function(WorkoutGroup) editGroup;
  GlobalWorkoutGroup({
    Key? key,
    required this.workoutGroup,
    required this.index,
    required this.deleteGroup,
    required this.editGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromRGBO(226, 226, 226, 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          // Card for on set
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Group ${index + 1}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => editGroup(workoutGroup),
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () => deleteGroup(workoutGroup),
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GlobalWorkoutSet(
                amount: workoutGroup.amount[0],
                measure: workoutGroup.measure[0],
                name: workoutGroup.exercises[0].name,
              ),
              if (workoutGroup.groupType == 'superset' ||
                  workoutGroup.groupType == 'circut')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GlobalWorkoutSet(
                    amount: workoutGroup.amount[1],
                    measure: workoutGroup.measure[1],
                    name: workoutGroup.exercises[1].name,
                  ),
                ),
              if (workoutGroup.groupType == 'circut')
                GlobalWorkoutSet(
                  amount: workoutGroup.amount[2],
                  measure: workoutGroup.measure[2],
                  name: workoutGroup.exercises[2].name,
                ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${workoutGroup.rest} Seconds Rest',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${workoutGroup.sets} Sets',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
