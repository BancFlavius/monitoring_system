import 'package:flutter/material.dart';

import 'fancy_button.dart';
import 'fancy_button_icon.dart';

class DigitKeypadOfficeReservation extends StatefulWidget {
  final ValueChanged<String> onDigitEntered;
  final double screenWidth;
  final double screenHeight;

  static String enteredDigits = '';
  const DigitKeypadOfficeReservation({super.key, required this.onDigitEntered, required this.screenWidth,required this.screenHeight});

  @override
  DigitKeypadOfficeReservationState createState() => DigitKeypadOfficeReservationState();
}

class DigitKeypadOfficeReservationState extends State<DigitKeypadOfficeReservation> {

  void enterDigit(String digit) {
    setState(() {
      if (DigitKeypadOfficeReservation.enteredDigits.length < 4) {
        DigitKeypadOfficeReservation.enteredDigits += digit;
      }
    });
    widget.onDigitEntered(DigitKeypadOfficeReservation.enteredDigits);
  }

  void deleteDigit() {
    setState(() {
      if (DigitKeypadOfficeReservation.enteredDigits.isNotEmpty) {
        DigitKeypadOfficeReservation.enteredDigits = DigitKeypadOfficeReservation.enteredDigits
            .substring(0, DigitKeypadOfficeReservation.enteredDigits.length - 1);
      }
    });
    widget.onDigitEntered(DigitKeypadOfficeReservation.enteredDigits);
  }

  void deleteAllDigits() {
    setState(() {
      DigitKeypadOfficeReservation.enteredDigits = '';
    });
    widget.onDigitEntered(DigitKeypadOfficeReservation.enteredDigits);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('1'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('2'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('3'),
          ],
        ),
        SizedBox(
          height: widget.screenHeight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('4'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('5'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('6'),
          ],
        ),
        SizedBox(
          height: widget.screenHeight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('7'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('8'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('9'),
          ],
        ),
        SizedBox(
          height: widget.screenHeight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildClearButton(),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDigitButton('0'),
            SizedBox(width: widget.screenWidth * 0.02,),
            buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget buildDigitButton(String digit) {
    return SizedBox(
      width: widget.screenWidth * 0.27,
      height: widget.screenHeight * 0.1,
      child: FancyButton(
        key: const Key('buildCode'),
        onPressed: () => enterDigit(digit),
        text: digit,
        fontSize: widget.screenWidth * 0.11,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        borderColor: Colors.lightBlueAccent,
        borderWidth: 4,
      ),
      // child: ElevatedButton(
      //   onPressed: () => enterDigit(digit),
      //   child: Text(
      //     digit,
      //     style: TextStyle(fontSize: widget.screenWidth * 0.15),
      //     key: const Key('buildCode'),
      //   ),
      // ),
    );
  }

  Widget buildClearButton() {
    return SizedBox(
      width: widget.screenWidth * 0.27,
      height: widget.screenHeight * 0.1,
      child:FancyButtonIcon(
        onPressed: deleteAllDigits,
        iconData: Icons.clear,
        iconSize: widget.screenWidth * 0.12,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        borderColor: Colors.redAccent,
        borderWidth: 3,
      ),
      // child: ElevatedButton(
      //   onPressed: deleteAllDigits,
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.red.shade800,
      //   ),
      //   child: Icon(
      //     Icons.clear,
      //     size: widget.screenWidth * 0.17,
      //   ),
      //
      // ),
    );
  }

  Widget buildDeleteButton() {
    return SizedBox(
      width: widget.screenWidth * 0.27,
      height: widget.screenHeight * 0.1,
      child: FancyButtonIcon(
        onPressed: deleteDigit,
        iconData: Icons.backspace,
        iconSize: widget.screenWidth * 0.12,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        borderColor: Colors.redAccent,
        borderWidth: 3,
      ),
      // child: ElevatedButton(
      //   onPressed: deleteDigit,
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.red.shade800,
      //   ),
      //   child: Icon(
      //     Icons.backspace,
      //     size: widget.screenWidth * 0.17,
      //   ),
      // ),
    );
  }
}
