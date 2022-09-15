import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';
import 'package:gym_workout_app/Components/Global/inputHeading.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class EditWorkoutGroupScreen extends StatefulWidget {
  final WorkoutGroup initialData;
  final List<ExerciseGroup> muscleGroups;
  final Function(String, dynamic, int?) onEditWorkoutGroup;
  final Function(WorkoutGroup) onSaveEdit;

  const EditWorkoutGroupScreen({
    Key? key,
    required this.muscleGroups,
    required this.onEditWorkoutGroup,
    required this.initialData,
    required this.onSaveEdit,
  }) : super(key: key);

  @override
  State<EditWorkoutGroupScreen> createState() => _EditWorkoutGroupScreenState();
}

class _EditWorkoutGroupScreenState extends State<EditWorkoutGroupScreen> {
  final Map<String, dynamic> _data = {
    'type': '',
    'exercise': {},
    'measure': {},
    'amount': {},
    'sets': 0,
    'rest': 0,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data['type'] = widget.initialData.groupType;
    _data['exercise'][0] = widget.initialData.exercises[0];
    _data['measure'][0] = widget.initialData.measure[0];
    _data['amount'][0] = widget.initialData.amount[0];
    if (_data['type'] == 'superset' || _data['type'] == 'circut') {
      _data['exercise'][1] = widget.initialData.exercises[1];
      _data['measure'][1] = widget.initialData.measure[1];
      _data['amount'][1] = widget.initialData.amount[1];
    }
    if (_data['type'] == 'circut') {
      _data['exercise'][2] = widget.initialData.exercises[2];
      _data['measure'][2] = widget.initialData.measure[2];
      _data['amount'][2] = widget.initialData.amount[2];
    }
    _data['sets'] = widget.initialData.sets;
    _data['rest'] = widget.initialData.rest;
  }

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
        singleController: widget.initialData.measure.length - 1 < index
            ? null
            : SingleValueDropDownController(
                data: DropDownValueModel(
                  name: _data['exercise'][index].name.toString().toTitleCase(),
                  value: _data['exercise'][index].name,
                ),
              ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Field cannot be empty";
          }
          return null;
        },
        onChanged: (value) {
          if (value != null && value.toString() != '') {
            // _data['exercises'][index] = value.value;
            _data['exercise'][index] = value.value;
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
          singleController: widget.initialData.measure.length - 1 < index
              ? null
              : SingleValueDropDownController(
                  data: DropDownValueModel(
                    name: _data['measure'][index].toString().toTitleCase(),
                    value: _data['measure'][index],
                  ),
                ),
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
              _data['measure'][index] = value.value;
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
        controller: widget.initialData.amount.length - 1 < index
            ? null
            : TextEditingController(
                text: _data['amount'][index].toString(),
              ),
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
            _data['amount'][index] = int.parse(value);
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
                        "Edit Group",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                  const GlobalInputHeading('Group Type'),
                  // Workout Group Type Selection
                  DropDownTextField(
                    singleController: SingleValueDropDownController(
                      data: DropDownValueModel(
                        name: _data['type'].toString().toTitleCase(),
                        value: _data['type'],
                      ),
                    ),
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
                        _data['type'] = value.value.toString();
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
                    controller: TextEditingController(
                      text: _data['rest'].toString(),
                    ),
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
                        _data['rest'] = int.parse(value);
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
                    singleController: SingleValueDropDownController(
                      data: DropDownValueModel(
                          name: widget.initialData.sets.toString(),
                          value: widget.initialData.sets),
                    ),
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
                        _data['sets'] = value.value;
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
                    onPressed: () async {
                      bool isValid = _formKey.currentState!.validate();
                      if (isValid) {
                        await widget.onSaveEdit(widget.initialData);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Save Changes"),
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
