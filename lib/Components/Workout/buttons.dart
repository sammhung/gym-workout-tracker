import 'package:flutter/material.dart';

class WorkoutButtons extends StatelessWidget {
  final Function onBack;
  final Function onNext;
  const WorkoutButtons({
    Key? key,
    required this.onBack,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => onBack(),
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () => onNext(),
          icon: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
