import 'package:ARRK/widgets/digit_keypad.dart';
import 'package:flutter/material.dart';

class CheckInBullet extends StatelessWidget {
  final Color color;
  final int index;
  final Size screenSize;

  const CheckInBullet({super.key, required this.screenSize, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    String digit = (color == Colors.blueAccent ? DigitKeypad.enteredDigits[index] : '');

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          size: screenSize.width * 0.15,
          color: color,
        ),
        Text(
          digit,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenSize.width * 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: screenSize.width * 0.1,
        ),
      ],
    );
  }
}
