import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Components/Home/WorkoutItem.dart';
import 'package:gym_workout_app/Pages/forms/createWorkout.dart';
import 'package:gym_workout_app/Providers/gym.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gym = Provider.of<Gym>(context);

    Future<void> setup() async {
      await gym.getExercises();
      await gym.loadWorkouts();
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back, Sam",
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Explore Your Workouts",
                style: Theme.of(context).textTheme.headline1,
              ),
              FutureBuilder(
                future: Future.wait([gym.getExercises(), gym.loadWorkouts()]),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final List<Workout> _workouts = gym.workouts;
                    return Expanded(
                      child: Column(
                        children: [
                          if (_workouts.isNotEmpty)
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  crossAxisCount: 2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                itemCount: _workouts.length,
                                itemBuilder: ((context, index) {
                                  return HomeWorkoutItem(
                                    workout: _workouts[index],
                                  );
                                }),
                              ),
                            ),
                          // Display message if workouts empty
                          if (_workouts.isEmpty)
                            SizedBox(
                              height: 65.h,
                              width: 100.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports_gymnastics,
                                    size: 30.w,
                                  ),
                                  SizedBox(
                                    height: 1.h,
                                  ),
                                  Text(
                                    "Add a workout to begin",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ),
      ),
      // Add Workout Button
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(CreateWorkout.routeName),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
