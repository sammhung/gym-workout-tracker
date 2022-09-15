import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_workout_app/Pages/forms/addExercise.dart';
import 'package:gym_workout_app/Pages/forms/createWorkout.dart';
import 'package:gym_workout_app/Pages/main/navigation.dart';
import 'package:gym_workout_app/Providers/auth.dart';
import 'package:gym_workout_app/Providers/exerciseProvider.dart';
import 'package:gym_workout_app/Providers/workoutProvider.dart';
import 'firebase_options.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';

import 'package:gym_workout_app/Pages/main/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExerciseProvider(),
        ),
        ChangeNotifierProxyProvider<ExerciseProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(),
          update: (_, exercise, workout) => WorkoutProvider(
            exerciseGroups: exercise.exerciseGroups,
            exercises: exercise.exercises,
          ),
        ),
        // ChangeNotifierProvider(
        //   create: (context) => Gym(),
        // ),
      ],
      child: ResponsiveSizer(
        builder: (ctx, orientation, screenType) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // Primary Color
              primaryColor: Colors.black,
              // Text Theme
              textTheme: TextTheme(
                headline1: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                ),
                bodyText2: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                headline5: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                headline6: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Textfield Theme
              inputDecorationTheme: const InputDecorationTheme(
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                  ),
                ),
              ),
              // Button Theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black,
                  ),
                ),
              ),
            ),
            routes: {
              AddExerciseScreen.routeName: (context) =>
                  const AddExerciseScreen(),
              CreateWorkout.routeName: (context) => const CreateWorkout(),
            },
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((context, snapshot) {
                User? user = snapshot.data;
                if (user != null) {
                  return const NavigationScreen();
                }
                return const AuthScreen();
              }),
            ),
          );
        },
      ),
    );
  }
}
