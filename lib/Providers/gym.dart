import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class Gym extends ChangeNotifier {
  List<ExerciseGroup> _exerciseGroups = [];
  List<Exercise> _exercises = [];
  List<String> _groupNames = [];
  final List<Workout> _workouts = [];

  List<ExerciseGroup> get exerciseGroups {
    return _exerciseGroups;
  }

  List<Exercise> get exercises {
    return _exercises;
  }

  List<String> get groupNames {
    return _groupNames;
  }

  List<Workout> get workouts {
    return _workouts;
  }

  Future<void> createWorkout(
    String workoutName,
    List<ExerciseGroup> exerciseGroups,
    List<WorkoutGroup> workoutGroups,
  ) async {
    int numExercises = 0;
    int restTime = 0;
    int numSets = 0;
    List<String> exerciseGroupNames = [];
    List<String> exerciseIds = [];
    for (var exerciseGroup in exerciseGroups) {
      exerciseGroupNames.add(exerciseGroup.name);
    }

    for (var workout in workoutGroups) {
      restTime += workout.rest;
      numExercises += workout.exercises.length;
      numSets += workout.sets;
      for (var exercise in workout.exercises) {
        exerciseIds.add(exercise.id);
      }
    }
    _workouts.add(
      Workout(
        numExercises: numExercises,
        restTime: restTime / 60,
        numSets: numSets,
        workoutName: workoutName,
        exerciseGroups: exerciseGroups,
        workoutGroups: workoutGroups,
      ),
    );
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutName.toLowerCase());

    await path.set({
      'numExercises': numExercises,
      'numSets': numSets,
      'restTime': restTime,
      'workoutName': workoutName.trim().toTitleCase(),
      'exerciseGroups': exerciseGroupNames,
    });

    for (var group in workoutGroups) {
      int index = workoutGroups.indexWhere((element) => element == group);
      await path.collection('workoutGroups').doc(index.toString()).set({
        'amount': group.amount,
        'groupType': group.groupType,
        'measure': group.measure,
        'rest': group.rest,
        'sets': group.sets,
        'exercises': exerciseIds,
      });
    }

    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    if (_workouts.isEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final documents = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .get();

      for (var doc in documents.docs) {
        final Workout workout = Workout(
          numExercises: int.parse(doc.data()['numExercises'].toString()),
          restTime: double.parse(doc.data()['restTime'].toString()),
          numSets: int.parse(doc.data()['numSets'].toString()),
          workoutName: doc.data()['workoutName'],
          exerciseGroups: [],
          workoutGroups: [],
        );

        for (var exercise in doc.data()['exerciseGroups']) {
          int index = _exerciseGroups
              .indexWhere((element) => element.name == exercise.toString());
          workout.exerciseGroups.add(_exerciseGroups[index]);
        }

        final documentsTwo = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .doc(doc.id)
            .collection('workoutGroups')
            .get();

        for (var doc2 in documentsTwo.docs) {
          final workoutGroup = WorkoutGroup(
              amount: [],
              rest: int.parse(doc2.data()['rest'].toString()),
              exercises: [],
              groupType: doc2.data()['groupType'].toString(),
              measure: [],
              sets: int.parse(doc2.data()['sets'].toString()));

          for (var measure in doc2.data()['measure']) {
            workoutGroup.measure.add(measure.toString());
          }

          for (var amount in doc2.data()['amount']) {
            workoutGroup.amount.add(int.parse(amount.toString()));
          }

          for (var exerciseId in doc2.data()['exercises']) {
            int index =
                _exercises.indexWhere((element) => element.id == exerciseId);
            workoutGroup.exercises.add(_exercises[index]);
          }
        }
        _workouts.add(workout);
      }
    }
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
  Future<void> getExercises() async {
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
          //_exercises.add(exerciseDetails);
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
