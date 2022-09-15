import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Providers/gym.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExerciseGroupDetails extends StatelessWidget {
  final ExerciseGroup exerciseGroup;
  const ExerciseGroupDetails({
    Key? key,
    required this.exerciseGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gym = Provider.of<Gym>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Name
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            exerciseGroup.name,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        // Group Exercises
        ...exerciseGroup.exercises.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              alignment: Alignment.centerLeft,
              height: 7.h,
              width: 90.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black,
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.name,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      // Delete button for custom
                      if (e.type == 'custom')
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        "You are about to delete an exercise"),
                                    content: const Text(
                                      "All data related to this exercise will be removed",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await gym.deleteExercise(
                                              e.category,
                                              e.id,
                                            );
                                          } catch (err) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    "An error occured when removing exercise. Please try again later"),
                                              ),
                                            );
                                          }

                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: Navigator.of(context).pop,
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            )),
                    ],
                  )),
            ),
          ),
        )
      ],
    );
  }
}
