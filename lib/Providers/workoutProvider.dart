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
  List<Exercise>? exercises;
  List<ExerciseGroup>? exerciseGroups;

  List<Workout> _workouts = [];
  List<Workout> get workouts {
    return _workouts;
  }

  void update(
    List<Exercise> newExercises,
    List<ExerciseGroup> newExerciseGroups,
  ) {
    exercises = newExercises;
    exerciseGroups = newExerciseGroups;
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

    // Load all the group name (this is whats stored in the database)
    for (var exerciseGroup in exerciseGroups) {
      exerciseGroupNames.add(exerciseGroup.name);
    }

    // Load the workout data (rest, numExercises and numeSets) and exerciseIds
    for (var workoutGroup in workoutGroups) {
      restTime += workoutGroup.rest;
      numExercises += workoutGroup.exercises.length;
      numSets += workoutGroup.sets;
      // Load all exercise IDs
      for (var exercise in workoutGroup.exercises) {
        if (!exerciseIds.contains(exercise.id)) {
          exerciseIds.add(exercise.id);
        }
      }
    }

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    // Path to workout DB
    final DocumentReference path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutName.toLowerCase());

    // Set the default workout data (No PR or WorkoutGroups set yet)
    await path.set({
      'numExercises': numExercises,
      'exercises': exerciseIds,
      'numSets': numSets,
      'restTime': restTime,
      'workoutName': workoutName.trim().toTitleCase(),
      'exerciseGroups': exerciseGroupNames,
    });

    // Save each individual group data
    for (var group in workoutGroups) {
      // Get the group index (Used as ID)
      int index = workoutGroups.indexWhere((element) => element == group);

      List<PersonalRecord> personalRecords = [];
      // this is what is stored in the database.
      List<Map<String, dynamic>> personRecordsDb = [];
      // Create a personal record item for each exercise in a group
      for (Exercise exercise in group.exercises) {
        int exerciseIndex =
            group.exercises.indexWhere((element) => element == exercise);

        final PersonalRecord personalRecord = PersonalRecord(
          amount: null,
          exercise: exercise,
          measure: group.measure[exerciseIndex],
          weight: null,
        );
        personRecordsDb.add({
          'amount': null,
          'exercise': exercise.id,
          'measure': group.measure[exerciseIndex],
          'weight': null,
        });
        personalRecords.add(personalRecord);
      }

      // Initialize the workoutGroup PR records (Not set by default)
      int groupIndex =
          workoutGroups.indexWhere((element) => element.id == group.id);
      workoutGroups[groupIndex].personalRecords = personalRecords;

      // Store the workout group in DB
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
        'personalRecords': personRecordsDb,
      });
    }

    final Workout workout = Workout(
      numExercises: numExercises,
      restTime: restTime / 60,
      numSets: numSets,
      workoutName: workoutName,
      exerciseGroups: exerciseGroups,
      workoutGroups: workoutGroups,
    );

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
    );
    int index = _workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
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
    int workoutIndex = _workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
    final List<String> exerciseIds = [];
    final List<PersonalRecord> personalRecords = [];
    final List<Map<String, dynamic>> personalRecordsDB = [];
    for (final exercise in group.exercises) {
      exerciseIds.add(exercise.id);
      int exerciseIndex =
          group.exercises.indexWhere((element) => element == exercise);
      personalRecords.add(
        PersonalRecord(
            amount: null,
            exercise: exercise,
            measure: group.measure[exerciseIndex],
            weight: null),
      );
      personalRecordsDB.add({
        'amount': null,
        'exercise': exercise.id,
        'measure': group.measure[exerciseIndex],
        'weight': null,
      });
    }
    // Ininitialize the PersonalRecords (Empty array by default)
    group.personalRecords = personalRecords;
    // Add the new group
    _workouts[workoutIndex].workoutGroups.add(group);
    notifyListeners();

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final path = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("workouts")
        .doc(
          workout.workoutName.toLowerCase(),
        );
    // Store new data in DB
    await path
        .collection('workoutGroups')
        .doc((_workouts[workoutIndex].workoutGroups.length - 1).toString())
        .set({
      'amount': group.amount,
      'exercises': exerciseIds,
      'measure': group.measure,
      'rest': group.rest,
      'sets': group.sets,
      'personalRecords': personalRecordsDB,
    });
    await calculateWorkoutDetails(workout);
  }

  Future<void> deleteWorkoutGroup(Workout workout, WorkoutGroup group) async {
    int workoutIndex = _workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
    print("Workout Index: ${workoutIndex}");
    int groupIndex = _workouts[workoutIndex]
        .workoutGroups
        .indexWhere((element) => element.id == group.id);
    print("Group Index: ${groupIndex}");
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
          // DELETE ALL
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
    int workoutIndex = _workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
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
      print(index);
      List<String> exerciseIds = [];
      List<Map<String, dynamic>> personalRecords = [];
      for (var exerciseGroup in group.exercises) {
        exerciseIds.add(exerciseGroup.id);
      }
      for (var personalRecord in group.personalRecords) {
        personalRecords.add({
          'amount': personalRecord.amount,
          'exercise': personalRecord.exercise.id,
          'measure': personalRecord.measure,
          'weight': personalRecord.weight
        });
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
        'personalRecords': personalRecords,
      });
    }
  }

  Future<void> saveEditGroup(
    Workout workout,
    WorkoutGroup oldGroup,
    WorkoutGroup newGroup,
  ) async {
    // print("SAVING GROUP");
    newGroup.id = oldGroup.id;

    int workoutIndex = _workouts
        .indexWhere((element) => element.workoutName == workout.workoutName);
    int groupIndex = _workouts[workoutIndex]
        .workoutGroups
        .indexWhere((element) => element.id == oldGroup.id);
    _workouts[workoutIndex].workoutGroups[groupIndex] = newGroup;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> exerciseIds = [];
    List<Map<String, dynamic>> personalRecords = [];

    for (var exerciseGroup in newGroup.exercises) {
      exerciseIds.add(exerciseGroup.id);
    }
    for (var exercise in newGroup.exercises) {
      bool exists = false;
      int exerciseIndex =
          newGroup.exercises.indexWhere((element) => element == exercise);

      for (var personalRecord in oldGroup.personalRecords) {
        if (personalRecord.exercise == exercise) {
          exists = true;
          personalRecords.add({
            'amount': personalRecord.amount,
            'exercise': personalRecord.exercise.id,
            'measure': personalRecord.measure,
            'weight': personalRecord.weight
          });
        }
      }
      if (!exists) {
        personalRecords.add({
          'amount': null,
          'exercise': exercise.id,
          'measure': newGroup.measure[exerciseIndex],
          'weight': null,
        });
      }
    }

    // FIX PR CHANGES IN DB
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
      'personalRecords': personalRecords,
    });
    await calculateWorkoutDetails(workout);
    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    if (_workouts.isEmpty && exercises!.isNotEmpty) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      // Get all of the users workouts
      final documents = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .get();

      // Loop through each individual workout
      for (var workoutDoc in documents.docs) {
        final workoutData = workoutDoc.data();
        final Workout workout = Workout(
          numExercises: int.parse(workoutData['numExercises'].toString()),
          restTime: double.parse(workoutData['restTime'].toString()),
          numSets: workoutData['numSets'],
          workoutName: workoutData['workoutName'],
          exerciseGroups: [],
          workoutGroups: [],
        );

        // Loop through each exerciseGroup, find it in exercisGroups and store it workout
        for (String exerciseGroup in workoutData['exerciseGroups']) {
          int groupIndex = exerciseGroups!.indexWhere(
              (element) => element.name == exerciseGroup.toString());
          workout.exerciseGroups.add(exerciseGroups![groupIndex]);
        }
        // Get all the workout groups
        final workoutGroupDocuments = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .doc(workoutDoc.id)
            .collection('workoutGroups')
            .get();

        List<String> allExerciseIds = [];

        // Loop through each workout group
        for (final workoutGroupDoc in workoutGroupDocuments.docs) {
          List<PersonalRecord> personalRecords = [];
          final workoutGroupData = workoutGroupDoc.data();
          // Get all personal records
          for (var personalRecordData in workoutGroupData['personalRecords']) {
            int index = exercises!.indexWhere((element) =>
                element.id == personalRecordData['exercise'].toString());
            personalRecords.add(
              PersonalRecord(
                amount: personalRecordData['amount'] == null
                    ? null
                    : double.parse(personalRecordData['amount'].toString()),
                exercise: exercises![index],
                measure: personalRecordData['measure'].toString(),
                weight: personalRecordData['weight'] == null
                    ? null
                    : double.parse(personalRecordData['weight'].toString()),
              ),
            );
          }

          final WorkoutGroup workoutGroup = WorkoutGroup(
            id: workoutGroupDoc.id.toString(),
            amount: workoutGroupData['amount'].cast<int>(),
            rest: int.parse(workoutGroupData['rest'].toString()),
            // As it is stored as IDs in database, will be loaded later
            exercises: [],
            personalRecords: personalRecords,
            groupType: workoutGroupData['groupType'].toString(),
            measure: workoutGroupData['measure'].cast<String>(),
            sets: int.parse(workoutGroupData['sets'].toString()),
          );
          // Loop through each exerciseId, find exercise and store it
          for (String exerciseId in workoutGroupData['exercises']) {
            final int exerciseIndex = exercises!
                .indexWhere((element) => element.id == exerciseId.toString());
            workoutGroup.exercises.add(exercises![exerciseIndex]);
            // If the exercise has not been added to the ids yet
            if (!allExerciseIds.contains(exerciseId)) {
              allExerciseIds.add(exerciseId);
            }
          }
          // Add loaded data to workout
          workout.workoutGroups.add(workoutGroup);
        }
        _workouts.add(workout);
      }
    }
  }
}
