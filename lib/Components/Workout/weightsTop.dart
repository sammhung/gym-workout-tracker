import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Components/Workout/buttons.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class RepsWeightTop extends StatelessWidget {
  final WorkoutGroup workoutGroup;
  final int exerciseIndex;
  final int setIndex;
  final Function onBack;
  final Function onNext;
  final Function(bool, double?, double) onPr;
  const RepsWeightTop({
    Key? key,
    required this.workoutGroup,
    required this.exerciseIndex,
    required this.setIndex,
    required this.onBack,
    required this.onNext,
    required this.onPr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Exercise exercise = workoutGroup.exercises[exerciseIndex];
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController weights = TextEditingController();
    final TextEditingController reps = TextEditingController();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                workoutGroup.exercises[exerciseIndex].name,
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '${workoutGroup.amount[exerciseIndex]} ${workoutGroup.measure[exerciseIndex].toTitleCase()}',
              ),
              const SizedBox(
                height: 10,
              ),
              Text('${setIndex + 1}/${workoutGroup.sets}')
            ],
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
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    } else if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    } else if (double.parse(value) < 0) {
                      return 'You cannot do reps less than 0';
                    } else if (double.parse(value) > 100) {
                      return 'You cannot do reps greater than 100';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  controller: reps,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Reps",
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
              if (_formKey.currentState!.validate()) {
                double? numWeights = double.tryParse(weights.value.text);
                double numReps = double.parse(reps.value.text);
                double? prWeights =
                    workoutGroup.personalRecords[exerciseIndex].weight;
                double? prAmount =
                    workoutGroup.personalRecords[exerciseIndex].weight;
                // PR has not been set
                if (prWeights == null && prAmount == null) {
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Set as new PR?"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              "You have not set a personal record for this group. Would you like to set this as your PR?"),
                          const SizedBox(
                            height: 10,
                          ),
                          if (numWeights != null)
                            Text("Weight: $numWeights KG"),
                          Text("Reps: ${numReps.round()}")
                        ],
                      ),
                      actions: [
                        // Close dialog and continue
                        TextButton(
                          onPressed: () {
                            onNext();
                            Navigator.of(context).pop();
                          },
                          child: const Text("No"),
                        ),
                        // Set PR
                        TextButton(
                          onPressed: () {
                            // Body Weight Exercise
                            if (numWeights == null) {
                              onPr(false, null, numReps);
                            }
                            // Weighted Exercise
                            onPr(true, numWeights, numReps);
                            onNext();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                }
                // PR has been set
                else {
                  bool willShowDialog = false;
                  // Body Weight Exercise (If doing more reps than PR)
                  if (numWeights == null && prAmount! < numReps) {
                    willShowDialog = true;
                    // Weights (If doing more weights with same or more reps)
                  } else if (prWeights! < numWeights! && prAmount! <= numReps) {
                    willShowDialog = true;
                  }

                  if (willShowDialog) {
                    showDialog(
                      useSafeArea: false,
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("You have beaten your PR!"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                "You have beaten your personal record! Would you like to set this as your new PR?"),
                            const SizedBox(
                              height: 10,
                            ),
                            if (numWeights != null)
                              Text("Old Weight: $prWeights KG"),
                            Text("Old Reps: ${prAmount!.round()}"),
                            const SizedBox(
                              height: 10,
                            ),
                            if (numWeights != null)
                              Text("Weight: $numWeights KG"),
                            Text("Reps: ${numReps.round()}")
                          ],
                        ),
                        actions: [
                          // Close dialog and continue
                          TextButton(
                            onPressed: () {
                              onNext();
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"),
                          ),
                          // Set PR
                          TextButton(
                            onPressed: () {
                              // Body Weight Exercise (If doing more reps than PR)
                              if (numWeights == null && prAmount < numReps) {
                                onPr(false, null, numReps);
                                // Weights (If doing more weights with same or more reps)
                              } else if (prWeights! < numWeights! &&
                                  prAmount <=
                                      workoutGroup.amount[exerciseIndex]) {
                                onPr(true, numWeights, numReps);
                              }
                              onNext();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
