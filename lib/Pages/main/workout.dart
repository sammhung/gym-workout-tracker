import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Components/Global/PersonaRecordItem.dart';
import 'package:gym_workout_app/Components/WorkoutDetails/appbar.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailsScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutDetailsAppbar(workout: workout),
              const SizedBox(
                height: 15,
              ),
              // Personal Records
              Text(
                "Personal Records",
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    crossAxisCount: 2,
                  ),
                  children: workout.personalRecords
                      .map(
                        (personalRecord) => PersonalRecordItem(
                          personalRecord: personalRecord,
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(
          Icons.play_arrow,
        ),
      ),
    );
  }
}
