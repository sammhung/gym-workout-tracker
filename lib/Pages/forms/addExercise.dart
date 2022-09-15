import 'package:flutter/material.dart';
import 'package:gym_workout_app/Components/AddExercise/form.dart';
import 'package:gym_workout_app/Components/Global/backButton.dart';

class AddExerciseScreen extends StatelessWidget {
  static const routeName = '/add-exercise-screen';
  const AddExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Back button
              GlobalBackButton(),
              AddExerciseForm(),
            ],
          ),
        ),
      ),
    );
  }
}
