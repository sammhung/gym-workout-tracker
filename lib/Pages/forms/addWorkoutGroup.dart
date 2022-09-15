import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';
import 'package:gym_workout_app/Components/Global/inputHeading.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddWorkoutGroupScreen extends StatefulWidget {
  final List<ExerciseGroup> muscleGroups;
  final Function(String, dynamic, int?) onEditWorkoutGroup;
  final Function addGroup;
  const AddWorkoutGroupScreen({
    Key? key,
    required this.muscleGroups,
    required this.onEditWorkoutGroup,
    required this.addGroup,
  }) : super(key: key);

  @override
  State<AddWorkoutGroupScreen> createState() => _AddWorkoutGroupScreenState();
}

class _AddWorkoutGroupScreenState extends State<AddWorkoutGroupScreen> {
  final Map<String, dynamic> _data = {
    'type': '',
    'measure': {
      0: '',
      1: '',
      2: '',
    },
  };
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Get all the exercies
    final List<Exercise> _exercises = [];
    widget.muscleGroups.forEach((muscleGroup) {
      muscleGroup.exercises.forEach((exercise) {
        _exercises.add(exercise);
      });
    });
    _exercises.sort(
      (a, b) => a.toString().toLowerCase().compareTo(
            b.toString().toLowerCase(),
          ),
    );

    Widget exercise(
      int index,
    ) {
      return DropDownTextField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Field cannot be empty";
          }
          return null;
        },
        onChanged: (value) {
          if (value != null && value.toString() != '') {
            widget.onEditWorkoutGroup('exercises', value.value, index);
          } else {
            widget.onEditWorkoutGroup('exercises', '', index);
          }
        },
        dropDownList: _exercises
            .map(
              (exercise) =>
                  DropDownValueModel(name: exercise.name, value: exercise),
            )
            .toList(),
      );
    }

    Widget measure(
      int index,
    ) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: DropDownTextField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Field cannot be empty";
            }
            return null;
          },
          textFieldDecoration: const InputDecoration(hintText: 'Reps or Time'),
          onChanged: (value) {
            if (value != null && value.toString() != '') {
              setState(() {
                _data['measure'][index] = value.value.toString().toLowerCase();
              });
              widget.onEditWorkoutGroup(
                'measure',
                value.value,
                index,
              );
            } else {
              widget.onEditWorkoutGroup('measure', '', index);
            }
          },
          dropDownList: const [
            DropDownValueModel(name: 'Time', value: 'time'),
            DropDownValueModel(name: 'Reps', value: 'reps'),
          ],
        ),
      );
    }

    Widget amount(int index) {
      return TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Field cannot be empty";
          } else if (int.tryParse(value) == null) {
            return "Please enter a valid number";
          } else {
            if (_data['measure'] == 'reps') {
              if (int.parse(value) > 20) {
                return "You are not doing more than 20 reps mate";
              } else if (int.parse(value) < 5) {
                return "Come on! You need more than 5 reps!";
              }
            } else {
              if (int.parse(value) < 5) {
                return "Ain't no workout is under 5 seconds";
              } else if (int.parse(value) > 600) {
                return "Don't overload yourself buddy";
              }
            }
          }
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            widget.onEditWorkoutGroup('amount', int.parse(value), index);
          } else {
            widget.onEditWorkoutGroup('amount', 0, index);
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: _data['measure'][index] == 'reps'
              ? 'Number Of Reps'
              : "Duration (Seconds)",
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const GlobalBackButton(),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        "Add Group",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                  const GlobalInputHeading('Group Type'),
                  // Workout Group Type Selection
                  DropDownTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field cannot be empty";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null && value.toString() != '') {
                        setState(() {
                          _data['type'] = value.value.toString().toLowerCase();
                        });
                        widget.onEditWorkoutGroup(
                            'groupType', value.value.toString(), null);
                      } else {
                        widget.onEditWorkoutGroup('groupType', '', null);
                      }
                    },
                    dropDownList: const [
                      DropDownValueModel(
                        name: "1 Set + Rest",
                        value: "1 set + rest",
                      ),
                      DropDownValueModel(
                        name: 'Superset',
                        value: 'superset',
                      ),
                      DropDownValueModel(
                        name: 'Circut',
                        value: 'circut',
                      )
                    ],
                  ),

                  const GlobalInputHeading(
                    'Exercise 1',
                  ),
                  exercise(0),
                  measure(0),
                  amount(0),
                  if (_data['type'] == 'superset' || _data['type'] == 'circut')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GlobalInputHeading(
                          'Exercise 2',
                        ),
                        exercise(1),
                        measure(1),
                        amount(1),
                      ],
                    ),

                  if (_data['type'] == 'circut')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GlobalInputHeading(
                          'Exercise 3',
                        ),
                        exercise(2),
                        measure(2),
                        amount(2),
                      ],
                    ),

                  // Rest Duration in minutes
                  const GlobalInputHeading('Rest Duration (Seconds)'),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field cannot be empty";
                      } else if (int.tryParse(value) == null) {
                        return "Please enter a number";
                      } else if (int.parse(value) < 10) {
                        return "You need at least 10 seconds of rest";
                      } else if (int.parse(value) > 300) {
                        return "How much rest do you need mate? Cut it down!";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        widget.onEditWorkoutGroup(
                            'rest', int.parse(value), null);
                      } else {
                        widget.onEditWorkoutGroup('rest', 0, null);
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: "Rest time in between sets"),
                  ),
                  // Number of sets
                  const GlobalInputHeading('Sets'),
                  DropDownTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field cannot be empty";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null && value.toString() != '') {
                        widget.onEditWorkoutGroup(
                          'sets',
                          value.value,
                          null,
                        );
                      } else {
                        widget.onEditWorkoutGroup('sets', 0, null);
                      }
                    },
                    dropDownList: const [
                      DropDownValueModel(name: '1', value: 1),
                      DropDownValueModel(name: '2', value: 2),
                      DropDownValueModel(name: '3', value: 3),
                      DropDownValueModel(name: '4', value: 4),
                      DropDownValueModel(name: '5', value: 5),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      bool isValid = _formKey.currentState!.validate();
                      if (isValid) {
                        widget.addGroup();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Add Group"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
