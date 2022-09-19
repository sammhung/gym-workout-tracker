import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Global/WorkoutGroup.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';
import 'package:gym_workout_app/Pages/forms/addWorkoutGroup.dart';
import 'package:gym_workout_app/Pages/forms/editWorkoutGroup.dart';
import 'package:gym_workout_app/Providers/workoutProvider.dart';
import 'package:provider/provider.dart';

class ViewWorkoutScreen extends StatefulWidget {
  final Workout workout;
  const ViewWorkoutScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<ViewWorkoutScreen> createState() => _ViewWorkoutScreenState();
}

class _ViewWorkoutScreenState extends State<ViewWorkoutScreen> {
  Map<String, dynamic> _workoutGroup = {
    'groupType': '',
    'exercises': {},
    'measure': {},
    'rest': 0,
    'sets': 0,
    'amount': {},
  };

  // This is passed to add workout page
  void onEditWorkoutGroup(String field, dynamic value, int? index) {
    if (index != null) {
      _workoutGroup[field][index] = value;
    } else {
      _workoutGroup[field] = value;
    }
  }

  late List<WorkoutGroup> _workoutGroups;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _workoutGroups = widget.workout.workoutGroups;
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    Future<void> deleteWorkoutGroup(WorkoutGroup workoutGroup) async {
      if (widget.workout.workoutGroups.length == 1) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("There is only one group left"),
                content: const Text(
                    "Removing this will delete this workout as well"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop,
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await workoutProvider.deleteWorkoutGroup(
                          widget.workout, workoutGroup);

                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            });
      } else {
        await workoutProvider.deleteWorkoutGroup(widget.workout, workoutGroup);
      }
    }

    Future<void> onSaveEdits(WorkoutGroup oldGroup) async {
      final WorkoutGroup _groupDetails = WorkoutGroup(
        id: null,
        amount: [],
        rest: _workoutGroup['rest'],
        exercises: [],
        groupType: _workoutGroup['groupType'],
        measure: [],
        personalRecords: [],
        sets: _workoutGroup['sets'],
      );

      if (_workoutGroup['groupType'] == '1 set + rest' ||
          _workoutGroup['groupType'] == 'superset' ||
          _workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][0]);
        _groupDetails.amount.add(_workoutGroup['amount'][0]);
        _groupDetails.measure.add(_workoutGroup['measure'][0]);
      }
      if (_workoutGroup['groupType'] == 'superset' ||
          _workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][1]);
        _groupDetails.amount.add(_workoutGroup['amount'][1]);
        _groupDetails.measure.add(_workoutGroup['measure'][1]);
      }
      if (_workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][2]);
        _groupDetails.amount.add(_workoutGroup['amount'][2]);
        _groupDetails.measure.add(_workoutGroup['measure'][2]);
      }

      // SEND TO PROVIDER
      await workoutProvider.saveEditGroup(
          widget.workout, oldGroup, _groupDetails);

      _workoutGroup = _workoutGroup = {
        'groupType': '',
        'exercises': {},
        'measure': {},
        'rest': 0,
        'sets': 0,
        'amount': {},
      };
    }

    Future<void> addGroup() async {
      final WorkoutGroup _groupDetails = WorkoutGroup(
        id: null,
        amount: [],
        rest: _workoutGroup['rest'],
        exercises: [],
        groupType: _workoutGroup['groupType'],
        measure: [],
        personalRecords: [],
        sets: _workoutGroup['sets'],
      );

      if (_workoutGroup['groupType'] == '1 set + rest' ||
          _workoutGroup['groupType'] == 'superset' ||
          _workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][0]);
        _groupDetails.amount.add(_workoutGroup['amount'][0]);
        _groupDetails.measure.add(_workoutGroup['measure'][0]);
      }
      if (_workoutGroup['groupType'] == 'superset' ||
          _workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][1]);
        _groupDetails.amount.add(_workoutGroup['amount'][1]);
        _groupDetails.measure.add(_workoutGroup['measure'][1]);
      }
      if (_workoutGroup['groupType'] == 'circut') {
        _groupDetails.exercises.add(_workoutGroup['exercises'][2]);
        _groupDetails.amount.add(_workoutGroup['amount'][2]);
        _groupDetails.measure.add(_workoutGroup['measure'][2]);
      }
      await workoutProvider.addWorkoutGroup(widget.workout, _groupDetails);
    }

    Future<void> adjustOrder() async {
      await workoutProvider.adjustOrder(widget.workout, _workoutGroups);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlobalBackButton(),
                  const Spacer(),
                  Text(
                    "Your Workout",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => AddWorkoutGroupScreen(
                          muscleGroups: widget.workout.exerciseGroups,
                          onEditWorkoutGroup: onEditWorkoutGroup,
                          addGroup: addGroup,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) async {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final WorkoutGroup item =
                            _workoutGroups.removeAt(oldIndex);
                        _workoutGroups.insert(newIndex, item);
                      });
                      await adjustOrder();
                    },
                    children: _workoutGroups.map((group) {
                      int groupIndex =
                          _workoutGroups.indexWhere((e) => e == group);
                      return GlobalWorkoutGroup(
                        key: GlobalKey(),
                        editGroup: (workout) {
                          _workoutGroup['groupType'] = workout.groupType;
                          _workoutGroup['exercises'][0] = workout.exercises[0];
                          _workoutGroup['measure'][0] = workout.measure[0];
                          _workoutGroup['amount'][0] = workout.amount[0];
                          _workoutGroup['sets'] = workout.sets;
                          if (_workoutGroup['groupType'] == 'superset' ||
                              _workoutGroup['groupType'] == 'circut') {
                            _workoutGroup['exercises'][1] =
                                workout.exercises[1];
                            _workoutGroup['measure'][1] = workout.measure[1];
                            _workoutGroup['amount'][1] = workout.amount[1];
                          }
                          if (_workoutGroup['groupType'] == 'circut') {
                            _workoutGroup['exercises'][2] =
                                workout.exercises[2];
                            _workoutGroup['measure'][2] = workout.measure[2];
                            _workoutGroup['amount'][2] = workout.amount[2];
                          }
                          _workoutGroup['rest'] = workout.rest;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => EditWorkoutGroupScreen(
                                initialData: workout,
                                muscleGroups: widget.workout.exerciseGroups,
                                onEditWorkoutGroup: onEditWorkoutGroup,
                                onSaveEdit: onSaveEdits,
                              ),
                            ),
                          );
                        },
                        workoutGroup: group,
                        index: groupIndex,
                        deleteGroup: deleteWorkoutGroup,
                      );
                    }).toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
