import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Workout/detailsBottom.dart';
import 'package:gym_workout_app/Components/Workout/quoteBottom.dart';
import 'package:gym_workout_app/Components/Workout/restTimerTop.dart';
import 'package:gym_workout_app/Components/Workout/timerTop.dart';
import 'package:gym_workout_app/Components/Workout/weightsTop.dart';
import 'package:gym_workout_app/Providers/workoutProvider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StartWorkoutScreen extends StatefulWidget {
  final Workout workout;
  const StartWorkoutScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen>
    with SingleTickerProviderStateMixin {
  bool isInit = true;
  // Start at workout 1
  bool isRest = false;
  int workoutGroupIndex = 0;
  int exerciseIndex = 0;
  int setIndex = 0;
  int restTime = 0;

  late TabController _tabController;
  int bottomSelectionIndex = 1;

  // Stopwatch controller
  final stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    // Index of workout group in all workouts
    final int workoutIndex = workoutProvider.workouts
        .indexWhere((element) => element == widget.workout);
    final Workout workout = workoutProvider.workouts[workoutIndex];
    // Index of group in workout
    final WorkoutGroup group =
        workoutProvider.workouts[workoutIndex].workoutGroups[workoutGroupIndex];
    final int numExercises = group.exercises.length;

    List<Widget> _bottomSection = [
      const WorkoutQuotesBottom(),
      WorkoutBottomDetails(
        personalRecords: group.personalRecords,
        exercise: group.exercises[exerciseIndex],
        setIndex: setIndex,
      ),
      Container(),
    ];

    void onNext() {
      // Turn of rest timer
      if (isRest) {
        setState(() {
          isRest = false;
          restTime = 0;

          // Change bottom screens
          _tabController.index = 1;
          bottomSelectionIndex = 1;
        });
      }
      // Finished all
      else if (setIndex + 1 == group.sets &&
          workoutGroupIndex + 1 == workout.workoutGroups.length &&
          exerciseIndex + 1 == group.exercises.length) {
        print("FINISHED ALL");
      }
      // More exercises to go (Next exercise)
      else if (exerciseIndex + 1 < numExercises) {
        setState(() {
          exerciseIndex += 1;
        });
      }
      // Went through all sets (Next Group)
      else if (setIndex + 1 == group.sets) {
        setState(() {
          restTime = group.rest;
          workoutGroupIndex += 1;
          setIndex = 0;
          exerciseIndex = 0;
          isRest = true;
          // Change bottom screens
          _tabController.index = 0;
          bottomSelectionIndex = 0;
        });
      }
      // Already went through all exercises (Next Set)
      else if (exerciseIndex + 1 == numExercises) {
        setState(() {
          restTime = group.rest;
          setIndex += 1;
          exerciseIndex = 0;
          isRest = true;
          // Change bottom screens
          _tabController.index = 0;
          bottomSelectionIndex = 0;
        });
      }
    }

    void onBack() {
      // If not first workout group and is first set and exercise
      if (isRest &&
          workoutGroupIndex > 0 &&
          setIndex == 0 &&
          exerciseIndex == 0) {
        setState(() {
          workoutGroupIndex -= 1;
          exerciseIndex =
              workout.workoutGroups[workoutGroupIndex].exercises.length - 1;
          setIndex = workout.workoutGroups[workoutGroupIndex].sets - 1;

          isRest = false;
        });
      }
      // Same condition but not rest
      else if (!isRest &&
          workoutGroupIndex > 0 &&
          setIndex == 0 &&
          exerciseIndex == 0) {
        setState(() {
          isRest = true;
        });
      }
      // Currently at rest for next set
      else if (isRest && setIndex >= 0 && exerciseIndex == 0) {
        setState(() {
          isRest = false;
          setIndex -= 1;
          exerciseIndex = group.exercises.length - 1;
        });
      }
      // If not the first exercise
      else if (workoutGroupIndex >= 0 && exerciseIndex > 0) {
        setState(() {
          exerciseIndex -= 1;
          isRest = false;
        });
      }

      // Second or more set and first exercise
      else if (setIndex > 0 && exerciseIndex == 0) {
        setState(() {
          isRest = true;
        });
      }
    }

    Future<void> logExercise(
      bool isWeight,
      double? weights,
      double amount,
    ) async {
      List<Map<String, dynamic>>? historyAmount =
          group.personalRecords[exerciseIndex].historyAmount;
      List<Map<String, dynamic>>? historyWeight =
          group.personalRecords[exerciseIndex].historyWeight;
      historyAmount?.add({
        'date': DateTime.now(),
        'amount': amount,
      });
      isWeight
          ? historyWeight?.add({
              'date': DateTime.now(),
              'weight': weights!,
            })
          : null;
      final PersonalRecord pr = PersonalRecord(
        // Amount stays the same
        amount: group.personalRecords[exerciseIndex].amount,
        exercise: group.exercises[exerciseIndex],
        measure: group.measure[exerciseIndex],
        // Weight stays the same
        weight: group.personalRecords[exerciseIndex].weight,
        historyAmount: historyAmount,
        historyWeight: historyWeight,
      );
      await workoutProvider.updatePr(workout, group, pr, exerciseIndex);
    }

    Future<void> onSetPr(bool isWeight, double? weights, double amount) async {
      List<Map<String, dynamic>>? historyAmount =
          group.personalRecords[exerciseIndex].historyAmount;
      List<Map<String, dynamic>>? historyWeight =
          group.personalRecords[exerciseIndex].historyWeight;
      historyAmount?.add({
        'date': DateTime.now(),
        'amount': amount,
      });
      isWeight
          ? historyWeight?.add({
              'date': DateTime.now(),
              'weight': weights!,
            })
          : null;

      final PersonalRecord pr = PersonalRecord(
        amount: amount,
        exercise: group.exercises[exerciseIndex],
        measure: group.measure[exerciseIndex],
        weight: weights,
        historyAmount: historyAmount,
        historyWeight: historyWeight,
      );
      await workoutProvider.updatePr(workout, group, pr, exerciseIndex);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: isInit ? 90.h : 50.h,
                width: 100.w,
                decoration: const BoxDecoration(color: Colors.black),
                child: isInit
                    // Play button on startup screen
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isInit = false;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outlined,
                                color: Colors.white,
                                size: 40.sp,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Start Workout",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Workout starting
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Navbar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.exit_to_app,
                                    color: Colors.white,
                                  ),
                                ),
                                // Display workout time
                                StreamBuilder<int>(
                                    stream: stopWatchTimer.rawTime,
                                    initialData: 0,
                                    builder: (context, snapshot) {
                                      stopWatchTimer.onStartTimer();
                                      final value = snapshot.data;
                                      final displayTime =
                                          StopWatchTimer.getDisplayTime(value!);
                                      return Text(
                                        'Duration: ${displayTime.toString().substring(1, 5)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Rubik',
                                          fontSize: 18.sp,
                                        ),
                                      );
                                    }),
                                Text(
                                  "${workoutGroupIndex + 1}/${workout.workoutGroups.length}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Rubik',
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                            // Top Section
                            if (group.measure[exerciseIndex] == 'reps' &&
                                !isRest)
                              RepsWeightTop(
                                workoutGroup: group,
                                exerciseIndex: exerciseIndex,
                                setIndex: setIndex,
                                onBack: onBack,
                                onNext: onNext,
                                onPr: onSetPr,
                                logExercise: logExercise,
                              ),
                            if (group.measure[exerciseIndex] == 'time' &&
                                !isRest)
                              TimerTop(
                                exerciseIndex: exerciseIndex,
                                onBack: onBack,
                                onNext: onNext,
                                setIndex: setIndex,
                                workoutGroup: group,
                                onPr: onSetPr,
                                logExercise: logExercise,
                              ),
                            if (isRest)
                              WorkoutRestTop(
                                time: restTime,
                                onBack: onBack,
                                onNext: onNext,
                              ),
                          ],
                        ),
                      ),
              ),
              // Bottom Section
              if (!isInit)
                Container(
                  height: 40.h,
                  width: 100.w,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Bottom Section Tab
                      TabBar(
                        onTap: (index) {
                          setState(() {
                            bottomSelectionIndex = index;
                          });
                        },
                        labelColor: Colors.black,
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.chat_bubble_outline),
                          ),
                          Tab(
                            // text: "Details",
                            icon: Icon(Icons.info_outline),
                          ),
                          Tab(
                            // text: "Friends",
                            icon: Icon(Icons.people_alt_outlined),
                          ),
                        ],
                      ),
                      // Bottom Section Display
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(5.w),
                          child: _bottomSection[bottomSelectionIndex],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
