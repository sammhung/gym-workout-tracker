import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GlobalBackButton extends StatelessWidget {
  const GlobalBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Navigator.of(context).pop,
      child: CircleAvatar(
        radius: 18.sp,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.arrow_left,
          color: Colors.white,
          size: 23.sp,
        ),
      ),
    );
  }
}
