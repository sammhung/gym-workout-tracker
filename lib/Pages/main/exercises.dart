import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Components/Exercise/GroupDetails.dart';
import 'package:gym_workout_app/Pages/forms/addExercise.dart';
import 'package:gym_workout_app/Providers/exerciseProvider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Exercises",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AddExerciseScreen.routeName);
                    },
                    icon: Icon(
                      Icons.add,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: exerciseProvider.loadExercises(),
                  builder: ((context, snapshot) {
                    final List<ExerciseGroup> data =
                        exerciseProvider.exerciseGroups;

                    if (snapshot.connectionState == ConnectionState.done) {
                      // List of workouts
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          // Each exercise group and cards
                          return ExerciseGroupDetails(exerciseGroup: data[i]);
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
