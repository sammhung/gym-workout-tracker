import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Classes/exercise.dart';
import 'package:gym_workout_app/Classes/exerciseGroup.dart';
import 'package:gym_workout_app/Classes/personalRecord.dart';
import 'package:gym_workout_app/Classes/workout.dart';
import 'package:gym_workout_app/Classes/workoutGroup.dart';
import 'package:gym_workout_app/Extensions/capitalize.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<Exercise>? exercises;
  final List<ExerciseGroup>? exerciseGroups;
  WorkoutProvider({this.exercises, this.exerciseGroups});

  final List<Workout> _workouts = [];
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

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutName.toLowerCase());

    await path.set({
      'numExercises': numExercises,
      'exercises': exerciseIds,
      'numSets': numSets,
      'restTime': restTime,
      'workoutName': workoutName.trim().toTitleCase(),
      'exerciseGroups': exerciseGroupNames,
    });

    for (var group in workoutGroups) {
      int index = workoutGroups.indexWhere((element) => element == group);
      await path
          .collection('workoutGroups')
          .doc(
            index.toString(),
          )
          .set({
        'amount': group.amount,
        'groupType': group.groupType,
        'measure': group.measure,
        'rest': group.rest,
        'sets': group.sets,
        'exercises': exerciseIds,
      });
      workoutGroups[index].id = index.toString();
    }

    final Workout workout = Workout(
        numExercises: numExercises,
        restTime: restTime / 60,
        numSets: numSets,
        workoutName: workoutName,
        exerciseGroups: exerciseGroups,
        workoutGroups: workoutGroups,
        personalRecords: []);

    for (var exerciseId in exerciseIds) {
      int index = exercises!.indexWhere((element) => element.id == exerciseId);
      workout.personalRecords.add(
        PersonalRecord(
            amount: null,
            exercise: exercises![index],
            measure: null,
            weight: null),
      );
    }

    _workouts.add(workout);

    notifyListeners();
  }

  Future<void> calculateWorkoutDetails(Workout workout) async {
    double restTime = 0;
    int numExercises = 0;
    int numSets = 0;
    workout.workoutGroups.forEach((workout) {
      restTime += workout.rest;
      numExercises += workout.exercises.length;
      numSets += workout.sets;
    });
    final Workout updatedWorkout = Workout(
      numExercises: numExercises,
      restTime: restTime,
      numSets: numSets,
      workoutName: workout.workoutName,
      exerciseGroups: workout.exerciseGroups,
      workoutGroups: workout.workoutGroups,
      personalRecords: workout.personalRecords,
    );
    int index = _workouts.indexWhere((element) => element == workout);
    _workouts[index] = updatedWorkout;
    notifyListeners();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(
          workout.workoutName.toLowerCase(),
        )
        .update({
      'numExercises': numExercises,
      'restTime': restTime,
      'numSets': numSets,
    });
  }

  Future<void> addWorkoutGroup(Workout workout, WorkoutGroup group) async {
    int workoutIndex = _workouts.indexWhere((element) => element == workout);
    _workouts[workoutIndex].workoutGroups.add(group);
    notifyListeners();
    final List<String> excerciseIds = [];
    group.exercises.forEach((excercise) => excerciseIds.add(excercise.id));
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("workouts")
        .doc(
          workout.workoutName.toLowerCase(),
        );
    // for (String exercise in excerciseIds) {
    //   if(workout.exercises.contains(exercise))
    //   await path.update({
    //     'exercises': FieldValue.arrayUnion([exercise]),
    //   });
    // }
    await path
        .collection('workoutGroups')
        .doc((_workouts[workoutIndex].workoutGroups.length - 1).toString())
        .set({
      'amount': group.amount,
      'exercises': excerciseIds,
      'measure': group.measure,
      'rest': group.rest,
      'sets': group.sets,
    });
    calculateWorkoutDetails(workout);
  }

  Future<void> deleteWorkoutGroup(Workout workout, WorkoutGroup group) async {
    int workoutIndex = _workouts.indexWhere((element) => element == workout);
    int groupIndex = _workouts[workoutIndex]
        .workoutGroups
        .indexWhere((element) => element == group);
    _workouts[workoutIndex].workoutGroups.remove(group);
    notifyListeners();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    // Delete workout if no more groups left
    if (workout.workoutGroups.length <= 1) {
      _workouts.remove(workout);
      notifyListeners();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("workouts")
          .doc(workout.workoutName.toLowerCase())
          .delete();
      return;
    }
    // Remove only the group
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection('workouts')
        .doc(workout.workoutName.toLowerCase())
        .collection('workoutGroups')
        .doc(group.id)
        .delete();

    await calculateWorkoutDetails(workout);
  }

  Future<void> adjustOrder(
    Workout workout,
    List<WorkoutGroup> newGroupOrder,
  ) async {
    int workoutIndex = _workouts.indexWhere((element) => element == workout);
    _workouts[workoutIndex].workoutGroups = newGroupOrder;
    notifyListeners();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(
          workout.workoutName.toLowerCase(),
        )
        .collection('workoutGroups');
    final documents = await path.get();

    // Remove all documents
    for (var doc in documents.docs) {
      await path.doc(doc.id).delete();
    }

    // Add all documents again
    for (var group in workout.workoutGroups) {
      final index = newGroupOrder.indexWhere((element) => element == group);
      List<String> exerciseIds = [];
      for (var exerciseGroup in group.exercises) {
        exerciseIds.add(exerciseGroup.id);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(_workouts[workoutIndex].workoutName.toLowerCase())
          .collection('workoutGroups')
          .doc(index.toString())
          .set({
        'amount': group.amount,
        'groupType': group.groupType,
        'measure': group.measure,
        'rest': group.rest,
        'sets': group.sets,
        'exercises': exerciseIds,
      });
    }
  }

  Future<void> saveEditGroup(
    Workout workout,
    WorkoutGroup oldGroup,
    WorkoutGroup newGroup,
  ) async {
    int workoutIndex = _workouts.indexWhere((element) => element == workout);
    int groupIndex = _workouts[workoutIndex]
        .workoutGroups
        .indexWhere((element) => element == oldGroup);
    _workouts[workoutIndex].workoutGroups[groupIndex] = newGroup;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> exerciseIds = [];
    for (var exerciseGroup in newGroup.exercises) {
      exerciseIds.add(exerciseGroup.id);
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(_workouts[workoutIndex].workoutName.toLowerCase())
        .collection('workoutGroups')
        .doc(groupIndex.toString())
        .set({
      'amount': newGroup.amount,
      'groupType': newGroup.groupType,
      'measure': newGroup.measure,
      'rest': newGroup.rest,
      'sets': newGroup.sets,
      'exercises': exerciseIds,
    });
    await calculateWorkoutDetails(workout);
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
          personalRecords: [],
        );

        for (var excerciseId in doc.data()['exercises']) {
          int index = exercises!
              .indexWhere((element) => element.id == excerciseId.toString());
          final pbDetail = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .doc(doc.id)
              .collection('personalRecords')
              .doc(exercises![index].id)
              .get();

          // Workout have not been tried yet
          if (pbDetail.data() == null) {
            workout.personalRecords.add(
              PersonalRecord(
                amount: null,
                exercise: exercises![index],
                measure: null,
                weight: null,
              ),
            );
          } else {
            workout.personalRecords.add(
              PersonalRecord(
                amount: int.parse(
                  pbDetail.data()!['amount'].toString(),
                ),
                exercise: exercises![index],
                measure: pbDetail.data()!['measure'].toString(),
                weight: double.parse(
                  pbDetail.data()!['amount'].toString(),
                ),
              ),
            );
          }
        }

        for (var exercise in doc.data()['exerciseGroups']) {
          int index = exerciseGroups!
              .indexWhere((element) => element.name == exercise.toString());
          workout.exerciseGroups.add(exerciseGroups![index]);
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
              id: doc2.id,
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
            int index = exercises!
                .indexWhere((element) => element.id == exerciseId.toString());
            workoutGroup.exercises.add(exercises![index]);
          }

          workout.workoutGroups.add(workoutGroup);
        }
        _workouts.add(workout);
      }
    }
  }
}
