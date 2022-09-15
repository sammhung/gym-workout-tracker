import 'package:flutter/material.dart';

class GlobalInputHeading extends StatelessWidget {
  final String text;
  const GlobalInputHeading(
    this.text,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
    ;
  }
}
