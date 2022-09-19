import 'package:flutter/material.dart';
import 'dart:math';

class WorkoutQuotesBottom extends StatelessWidget {
  const WorkoutQuotesBottom({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> quotes = [
      '"To be number one, you have to train like you\'re number two."',
      '“The more you sweat in training, the less you bleed in combat."',
      '"All progress takes place outside the comfort zone."',
      '"Weather you think you can, or you think you can\'t, you\'re right."',
      '"I have nothing in common with lazy people who blame others for their lack of success."',
      '"The vision of a champion is bent over, drenched in sweat, at the point of exhaustion when nobody else is looking."',
      '"The last three or four reps is what makes the muscle grow. This area of pain divides the champion from someone else who is not a champion"',
      '"Do what you have to do until you can do what you want to do."',
      '"If something stands between you and your success, move it. Never be denied."',
      '"Look in the mirror. That\'s your competition."',
      '"Most people fail, not because of lack of desire, but, because of lack of commitment."',
      '"Some people want it to happen, some wish it would happen, others make it happen."',
      '"The only person you are destined to become is the person you decide to be"',
      '"Today I will do what others won\'t, so tomorrow I can accomplish what others can\'t."',
    ];
    List<String> from = [
      "Maurice Green",
      "Navy Seal",
      "Michael John Bobak",
      "Henry Ford",
      "Kobe Bryant",
      "Mia Hamm",
      'Arnold Schwarzenegger',
      'Oprah Winfrey',
      "Dwayne Johnson",
      "John Assaraf",
      "Vince Lombardi",
      "Michael Jordan",
      "Ralph Waldo Emerson",
      "Jerry Rice",
    ];
    var rng = Random();
    int rand = rng.nextInt(quotes.length);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          quotes[rand],
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          from[rand],
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        )
      ],
    );
  }
}
