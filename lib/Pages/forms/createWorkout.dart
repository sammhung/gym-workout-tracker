import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Global/WorkoutGroup.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';
import 'package:gym_workout_app/Components/Global/inputHeading.dart';
import 'package:gym_workout_app/Components/Global/longButton.dart';
import 'package:gym_workout_app/Pages/forms/addWorkoutGroup.dart';
import 'package:gym_workout_app/Providers/gym.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CreateWorkout extends StatefulWidget {
  static const routeName = '/create-workout';
  const CreateWorkout({Key? key}) : super(key: key);

  @override
  State<CreateWorkout> createState() => _CreateWorkoutState();
}

class _CreateWorkoutState extends State<CreateWorkout> {
  Map<String, dynamic> _workoutGroup = {
    'groupType': '',
    'exercises': {},
    'measure': {},
    'rest': 0,
    'sets': 0,
    'amount': {},
  };
  final Map<String, dynamic> _data = {
    'name': '',
    // This groups is for muscle groups
    'groups': [],
  };

  // This is the list of all workouts
  final List<WorkoutGroup> _workoutGroups = [];

  // This is passed to add workout page
  void onEditWorkoutGroup(String field, dynamic value, int? index) {
    if (index != null) {
      _workoutGroup[field][index] = value;
    } else {
      _workoutGroup[field] = value;
    }
  }

  // Passed to add workout page
  void addGroup() {
    final WorkoutGroup _groupDetails = WorkoutGroup(
      amount: [],
      rest: _workoutGroup['rest'],
      exercises: [],
      groupType: _workoutGroup['groupType'],
      measure: [],
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

    setState(() {
      _workoutGroups.add(_groupDetails);
    });

    _workoutGroup = {
      'groupType': '',
      'exercises': {},
      'measure': {},
      'rest': 0,
      'sets': 0,
      'amount': {},
    };
  }

  void deleteGroup(WorkoutGroup workoutGroup) {
    setState(() {
      _workoutGroups.removeWhere((element) => element == workoutGroup);
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final gym = Provider.of<Gym>(context);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Back and title
            Row(
              children: [
                const GlobalBackButton(),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Create Workout",
                  style: Theme.of(context).textTheme.headline1,
                )
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlobalInputHeading("Workout Name"),
                    TextFormField(
                      onChanged: (value) {
                        _data['name'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Create a fancy name!",
                      ),
                    ),
                    // Select muscle groups
                    const GlobalInputHeading("Muscle Groups"),
                    DropDownTextField.multiSelection(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        }
                        return null;
                      },
                      isEnabled: _workoutGroups.isEmpty,
                      onChanged: (value) {
                        List<ExerciseGroup> items = [];
                        for (var item in value) {
                          var itemValue = item.value;
                          items.add(itemValue);
                        }

                        setState(() {
                          _data['groups'] = items;
                        });
                      },
                      displayCompleteItem: true,
                      dropDownList: gym.exerciseGroups
                          .map((exercise) => DropDownValueModel(
                              name: exercise.name, value: exercise))
                          .toList(),
                    ),
                    // Add Workouts
                    const GlobalInputHeading("Add Workout Group"),
                    // The Workout Groups displayed here
                    Expanded(
                      child: ReorderableListView(
                        onReorder: (
                          int oldIndex,
                          int newIndex,
                        ) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final WorkoutGroup item =
                                _workoutGroups.removeAt(oldIndex);
                            _workoutGroups.insert(newIndex, item);
                          });
                        },
                        children: [
                          ..._workoutGroups.map((group) {
                            final int index = _workoutGroups.indexWhere(
                              (element) => element == group,
                            );
                            return GlobalWorkoutGroup(
                              index: index,
                              workoutGroup: group,
                              deleteGroup: deleteGroup,
                              key: GlobalKey(),
                            );
                          }).toList()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    // Add Workouts
                    GlobalLongButton(
                      disabled: _data['groups'].isEmpty,
                      text: 'Add Workout Group',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddWorkoutGroupScreen(
                            addGroup: addGroup,
                            onEditWorkoutGroup: onEditWorkoutGroup,
                            muscleGroups: _data['groups'],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    // Create Workout
                    GlobalLongButton(
                      disabled: _workoutGroups.isEmpty,
                      text: 'Create Workout',
                      onPressed: () async {
                        bool isValid = _formKey.currentState!.validate();
                        if (isValid && _workoutGroups.isNotEmpty) {
                          await gym.createWorkout(
                            _data['name'],
                            _data['groups'],
                            _workoutGroups,
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
