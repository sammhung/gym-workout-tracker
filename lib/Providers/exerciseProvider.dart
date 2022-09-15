import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class ExerciseProvider extends ChangeNotifier {
  List<ExerciseGroup> _exerciseGroups = [];
  List<Exercise> _exercises = [];
  List<String> _groupNames = [];

  List<ExerciseGroup> get exerciseGroups {
    return _exerciseGroups;
  }

  List<Exercise> get exercises {
    return _exercises;
  }

  List<String> get groupNames {
    return _groupNames;
  }

  // Checks if exercise is created before adding it
  String? validateExercises(String groupName, String exerciseName) {
    int index = _exerciseGroups
        .indexWhere((exerciseGroup) => exerciseGroup.name == groupName);
    if (index < 0) {
      return null;
    }

    int i = _exerciseGroups[index].exercises.indexWhere(
          (exercise) =>
              exercise.name.toString().toLowerCase() ==
              exerciseName.toString().toLowerCase(),
        );
    if (i < 0) {
      return null;
    } else {
      return "Exercise already exists";
    }
  }

  Future<void> addExercise(
    String groupName,
    String exerciseName,
    String category,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .add(
      {
        'category': groupName,
        'name': exerciseName.toTitleCase(),
        'weightType': category.toLowerCase(),
        'type': 'custom',
      },
    );

    // Add in memory
    int index = _exerciseGroups
        .indexWhere((exerciseGroup) => exerciseGroup.name == groupName);
    _exerciseGroups[index].exercises.add(
          Exercise(
            id: data.id,
            category: groupName,
            name: exerciseName.toTitleCase(),
            weightType: category.toTitleCase(),
            type: 'custom',
          ),
        );

    _exerciseGroups[index].exercises.sort(
          (a, b) => a.name.toString().compareTo(
                b.name.toString(),
              ),
        );
    notifyListeners();
  }

  Future<void> deleteExercise(
    String groupName,
    String id,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .doc(id)
        .delete();

    // Remove in memory
    int index = _exerciseGroups
        .indexWhere((exerciseGroup) => exerciseGroup.name == groupName);
    _exerciseGroups[index].exercises.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // Load all exercises and groups
  Future<void> loadExercises() async {
    if (_exerciseGroups.isEmpty || _groupNames.isEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final List<String> exerciseGroupNames = [];
      final List<ExerciseGroup> exercisesGroupLOAD = [];
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .get();

      for (var doc in data.docs) {
        // Exercise Group not yet created
        Exercise exerciseDetails = Exercise(
          id: doc.id,
          category: doc.data()['category'],
          name: doc.data()['name'],
          type: doc.data()['type'],
          weightType: doc.data()['weightType'],
        );
        if (!exerciseGroupNames.contains(doc.data()['category'])) {
          exerciseGroupNames.add(doc.data()['category']);
          exercisesGroupLOAD.add(
            ExerciseGroup(
              name: doc.data()['category'],
              exercises: [
                exerciseDetails,
              ],
            ),
          );
          _exercises.add(exerciseDetails);
        }

        // Exercise Group already created
        else {
          final int index = exercisesGroupLOAD.indexWhere(
            (exerciseGroup) => exerciseGroup.name == doc.data()['category'],
          );

          Exercise exerciseDetails = Exercise(
            id: doc.id,
            category: doc.data()['category'],
            name: doc.data()['name'],
            type: doc.data()['type'],
            weightType: doc.data()['weightType'],
          );

          exercisesGroupLOAD[index].exercises.add(exerciseDetails);

          _exercises.add(exerciseDetails);

          // Sort the exercises
          exercisesGroupLOAD[index].exercises.sort(
                (a, b) => a.name.toString().compareTo(
                      b.name.toString(),
                    ),
              );
        }
      }
      // Sort the list of exercises
      exercisesGroupLOAD.sort((a, b) {
        return a.name.compareTo(b.name);
      });

      // Sort the exercise group names
      exerciseGroupNames.sort((a, b) {
        return a.compareTo(b);
      });

      _groupNames = exerciseGroupNames;
      _exerciseGroups = exercisesGroupLOAD;
      notifyListeners();
    }
  }
}
