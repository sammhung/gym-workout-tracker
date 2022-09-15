import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  // Create user
  Future<void> signUp(Map<String, String> userDetails) async {
    try {
      // Creates User
      final UserCredential credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userDetails['email']!, password: userDetails['password']!);
      // Save User Data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credentials.user!.uid)
          .set({
        'fName': userDetails['fName'],
        'weight': double.parse(userDetails['weight']!),
        'height': double.parse(userDetails['height']!),
      });
      // Create default exercises
      final List<Map<String, String>> _exercises = [
        {
          'category': 'Chest',
          'name': 'Bench Press',
          'type': 'default',
          'weightType': 'weights',
        },
        {
          'category': 'Back',
          'name': 'Lat Pull Down',
          'type': 'default',
          'weightType': 'weights',
        },
        {
          'category': 'Abs',
          'name': 'Sit Ups',
          'type': 'default',
          'weightType': 'body weights',
        },
        {
          'category': 'Chest',
          'name': 'Incline Bench Press',
          'type': 'default',
          'weightType': 'weights',
        },
        {
          'category': 'Arms',
          'name': 'Bicep Curls',
          'type': 'default',
          'weightType': 'weights',
        },
        {
          'category': 'Arms',
          'name': 'Tricep Dips',
          'type': 'default',
          'weightType': 'body weights',
        },
        {
          'category': 'Arms',
          'name': 'Shoulder Press',
          'type': 'default',
          'weightType': 'weights',
        }
      ];
      for (var exercise in _exercises) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(credentials.user!.uid)
            .collection("exercises")
            .add(exercise);
      }
    } catch (err) {
      rethrow;
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (err) {
      rethrow;
    }
  }
}
