import 'package:flutter/material.dart';

class DigitKeypadTablet extends StatefulWidget {
  final ValueChanged<String> onDigitEntered;

  static String enteredDigits = '';
  const DigitKeypadTablet({super.key, required this.onDigitEntered});

  @override
  DigitKeypadTabletState createState() => DigitKeypadTabletState();
}

class DigitKeypadTabletState extends State<DigitKeypadTablet> {

  void enterDigit(String digit) {
    setState(() {
      if (DigitKeypadTablet.enteredDigits.length < 4) {
        DigitKeypadTablet.enteredDigits += digit;
      }
    });
    widget.onDigitEntered(DigitKeypadTablet.enteredDigits);
  }

  void deleteDigit() {
    setState(() {
      if (DigitKeypadTablet.enteredDigits.isNotEmpty) {
        DigitKeypadTablet.enteredDigits = DigitKeypadTablet.enteredDigits
            .substring(0, DigitKeypadTablet.enteredDigits.length - 1);
      }
    });
    widget.onDigitEntered(DigitKeypadTablet.enteredDigits);
  }

  void deleteAllDigits() {
    setState(() {
      DigitKeypadTablet.enteredDigits = '';
    });
    widget.onDigitEntered(DigitKeypadTablet.enteredDigits);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('1'),
            buildDigitButton('2'),
            buildDigitButton('3'),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('4'),
            buildDigitButton('5'),
            buildDigitButton('6'),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildDigitButton('7'),
            buildDigitButton('8'),
            buildDigitButton('9'),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildClearButton(),
            buildDigitButton('0'),
            buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget buildDigitButton(String digit) {
    return ElevatedButton(
      onPressed: () => enterDigit(digit),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(130, 130), // Set the desired width and height here
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 50.0),//24 for mobile
        key: const Key('buildCode'),

      ),
    );
  }

  Widget buildClearButton() {
    return ElevatedButton(
      onPressed: deleteAllDigits,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(130, 130), // Set the desired width and height here
        backgroundColor: Colors.red.shade800,
      ),
      child: const Icon(
        Icons.clear,
        size: 50,
      ),
    );
  }

  Widget buildDeleteButton() {
    return ElevatedButton(
      onPressed: deleteDigit,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(130, 130), // Set the desired width and height here
        backgroundColor: Colors.red.shade800,
      ),
      child: const Icon(
        Icons.backspace,
        size: 50,
      ),
    );
  }
}
