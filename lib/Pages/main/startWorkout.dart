import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Workout/detailsBottom.dart';
import 'package:gym_workout_app/Components/Workout/quoteBottom.dart';
import 'package:gym_workout_app/Components/Workout/restTimerTop.dart';
import 'package:gym_workout_app/Components/Workout/timerTop.dart';
import 'package:gym_workout_app/Components/Workout/weightsTop.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    final WorkoutGroup group = widget.workout.workoutGroups[workoutGroupIndex];
    final int numExercises = group.exercises.length;
    String nextExercise = '';
    // Same exercise
    if (exerciseIndex + 1 < numExercises) {
      nextExercise = group.exercises[exerciseIndex + 1].name;
      // No more exercises
    } else if (workoutGroupIndex + 1 == widget.workout.workoutGroups.length) {
      nextExercise = 'NO MORE';
    }
    // Next Group
    else {
      nextExercise =
          widget.workout.workoutGroups[workoutGroupIndex + 1].exercises[0].name;
    }

    List<Widget> _bottomSection = [
      const WorkoutQuotesBottom(),
      WorkoutBottomDetails(
        personalRecords: group.personalRecords,
        exercise: group.exercises[exerciseIndex],
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
          workoutGroupIndex + 1 == widget.workout.workoutGroups.length &&
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

      print('$workoutGroupIndex  $exerciseIndex  $setIndex');
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
              widget.workout.workoutGroups[workoutGroupIndex].exercises.length -
                  1;
          setIndex = widget.workout.workoutGroups[workoutGroupIndex].sets - 1;

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

    void onSetPr(bool isWeight, double? weights, double amount) {
      print("SETTING PR");
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
                          child: Icon(
                            Icons.play_circle_outlined,
                            color: Colors.white,
                            size: 30.sp,
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
                                Text(
                                  "Next: $nextExercise",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Rubik',
                                    fontSize: 18.sp,
                                  ),
                                ),
                                Text(
                                  "${workoutGroupIndex + 1}/${widget.workout.workoutGroups.length}",
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
