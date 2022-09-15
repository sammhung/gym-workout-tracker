import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GlobalLongButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool disabled;
  const GlobalLongButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!disabled) {
          onPressed();
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 15.w,
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: disabled ? Colors.grey : Colors.black,
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyText2),
      ),
    );
  }
}
