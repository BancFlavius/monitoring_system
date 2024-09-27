import 'package:flutter/material.dart';

import 'digit_keypad_constant.dart';

class CheckInBulletConstant extends StatelessWidget {
  final Color color;
  final int index;

  const CheckInBulletConstant({super.key,required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    String digit = (color == Colors.blueAccent ? DigitKeypadConstant.enteredDigits[index] : '');

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          size: 60,
          color: color,
        ),
        Text(
          digit,
          style: TextStyle(
            color: Colors.black,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 12,
        ),
      ],
    );
  }
}