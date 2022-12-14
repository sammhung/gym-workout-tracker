import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gym_workout_app/Pages/main/exercises.dart';
import 'package:gym_workout_app/Pages/main/home.dart';
import 'package:gym_workout_app/Pages/main/profile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    ExercisesScreen(),
    Container(),
    ProfileScreen(),
  ];
  int _index = 0;

  // Select Screen
  void onSelect(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onSelect,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Exercises",
            icon: Icon(Icons.sports_gymnastics),
          ),
          BottomNavigationBarItem(
            label: "Friends",
            icon: Icon(Icons.people),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
      ),
    );
  }
}
