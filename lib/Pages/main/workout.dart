import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Components/Global/PersonaRecordItem.dart';
import 'package:gym_workout_app/Components/Global/WorkoutGroup.dart';
import 'package:gym_workout_app/Pages/main/startWorkout.dart';
import 'package:gym_workout_app/Components/WorkoutDetails/appbar.dart';
import 'package:gym_workout_app/Providers/workoutProvider.dart';
import 'package:provider/provider.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailsScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<WorkoutProvider>(context).workouts;
    final int workoutIndex = workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutDetailsAppbar(workout: workouts[workoutIndex]),
              const SizedBox(
                height: 15,
              ),
              // Personal Records
              Text(
                "Personal Records",
                style: Theme.of(context).textTheme.headline5,
              ),
              // List of personal records
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  children: workouts[workoutIndex].workoutGroups.map(
                    (group) {
                      final int index = workouts[workoutIndex]
                          .workoutGroups
                          .indexWhere(((element) => element.id == group.id));
                      return GlobalWorkoutGroup(
                        viewMode: true,
                        workoutGroup: group,
                        index: index,
                        // These functions are not used
                        deleteGroup: (e) {},
                        editGroup: (e) {},
                      );
                    },
                  ).toList(),
                ),
              )
            ],
          ),
        ),
      ),
      // Start workout
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => StartWorkoutScreen(
                workout: workouts[workoutIndex],
              ),
            ),
          );
        },
        child: const Icon(
          Icons.play_arrow,
        ),
      ),
    );
  }
}
