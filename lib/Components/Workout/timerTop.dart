import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Workout/buttons.dart';
import 'package:gym_workout_app/Components/Workout/stopwatch.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class TimerTop extends StatelessWidget {
  final WorkoutGroup workoutGroup;
  final int exerciseIndex;
  final int setIndex;
  final Function onBack;
  final Function onNext;
  final Function(bool, double?, double) onPr;
  const TimerTop({
    Key? key,
    required this.exerciseIndex,
    required this.onBack,
    required this.onNext,
    required this.setIndex,
    required this.workoutGroup,
    required this.onPr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController weights = TextEditingController();
    int timeAdded = 0;
    int timeSpent = 0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: StopWatch(
              time: workoutGroup.amount[exerciseIndex],
              title: workoutGroup.exercises[exerciseIndex].name,
              subtitle: '${setIndex + 1}/${workoutGroup.sets}',
              onAdd: (time) => timeAdded += time,
              getTimeSpent: (time) => timeSpent = time,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (workoutGroup.exercises[exerciseIndex].weightType ==
                    'weights')
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field cannot be empty";
                      } else if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      } else if (double.parse(value) < 0) {
                        return "Your weight cannot be smaller than 0";
                      } else if (double.parse(value) > 2840) {
                        return "No way. Please enter a smaller value";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    controller: weights,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Weights (KG)",
                      suffixText: 'KG',
                      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          WorkoutButtons(
            onBack: onBack,
            onNext: () {
              double? prTime =
                  workoutGroup.personalRecords[exerciseIndex].amount;
              double? prWeight =
                  workoutGroup.personalRecords[exerciseIndex].weight;
              double? weight = double.tryParse(weights.value.text);
              // PR hasn't been set
              if (_formKey.currentState!.validate()) {
                if (prTime == null) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("PR hasn't been set"),
                      content: Column(
                        children: [
                          const Text(
                              "Your personal record hasn't been set. Would you like to set this as your PR?"),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Time: $timeSpent"),
                          if (weight != null) Text("Weight: $weight")
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              onNext();
                              Navigator.of(context).pop();
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () {
                              // No Weight added
                              if (weight == null) {
                                onPr(false, null, timeSpent.toDouble());
                              }
                              // Weight added
                              else {
                                onPr(false, weight, timeSpent.toDouble());
                              }
                              onNext();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Yes")),
                      ],
                    ),
                  );
                }
                // PR is sest
                else {
                  if (timeSpent > prTime) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("You have beaten your PR!"),
                        content: Column(
                          children: [
                            const Text(
                                "You have beaten your personal record! Would you like to set this as your new one?"),
                            const SizedBox(
                              height: 10,
                            ),
                            if (weight != null) Text("Old Weight: $prWeight"),
                            Text("Old Time: $prTime"),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("New Weight: $weight"),
                            Text("New Time: $timeSpent")
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                onNext();
                                Navigator.of(context).pop();
                              },
                              child: const Text("No")),
                          TextButton(
                              onPressed: () {
                                // No Weight added
                                if (weight == null) {
                                  onPr(false, null, timeSpent.toDouble());
                                }
                                // Weight added
                                else {
                                  onPr(false, weight, timeSpent.toDouble());
                                }
                                onNext();
                                Navigator.of(context).pop();
                              },
                              child: const Text("Yes")),
                        ],
                      ),
                    );
                  }
                }
                onNext();
              }
            },
          ),
        ],
      ),
    );
  }
}
