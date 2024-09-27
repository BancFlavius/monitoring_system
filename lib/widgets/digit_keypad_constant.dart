import 'package:flutter/material.dart';

import 'fancy_button.dart';
import 'fancy_button_icon.dart';

typedef DigitEnteredCallback = void Function({required BuildContext context,required String digits});

class DigitKeypadConstant extends StatefulWidget {
  final DigitEnteredCallback  onDigitEntered;
  final BuildContext buildContext;

  static String enteredDigits = '';
  const DigitKeypadConstant({super.key, required this.onDigitEntered, required this.buildContext});

  @override
  DigitKeypadConstantState createState() => DigitKeypadConstantState();
}

class DigitKeypadConstantState extends State<DigitKeypadConstant> {

  void enterDigit(String digit) {
    setState(() {
      if (DigitKeypadConstant.enteredDigits.length < 4) {
        DigitKeypadConstant.enteredDigits += digit;
      }
    });
    widget.onDigitEntered(digits: DigitKeypadConstant.enteredDigits,context: widget.buildContext);
  }

  void deleteDigit() {
    setState(() {
      if (DigitKeypadConstant.enteredDigits.isNotEmpty) {
        DigitKeypadConstant.enteredDigits = DigitKeypadConstant.enteredDigits
            .substring(0, DigitKeypadConstant.enteredDigits.length - 1);
      }
    });
    widget.onDigitEntered(digits: DigitKeypadConstant.enteredDigits,context: widget.buildContext);
  }

  void deleteAllDigits() {
    setState(() {
      DigitKeypadConstant.enteredDigits = '';
    });
    widget.onDigitEntered(digits: DigitKeypadConstant.enteredDigits,context: widget.buildContext);
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
            SizedBox(width: 30),
            buildDigitButton('2'),
            SizedBox(width: 30),
            buildDigitButton('3'),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('4'),
            SizedBox(width: 30),
            buildDigitButton('5'),
            SizedBox(width: 30,),
            buildDigitButton('6'),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('7'),
            SizedBox(width: 30),
            buildDigitButton('8'),
            SizedBox(width: 30),
            buildDigitButton('9'),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildClearButton(),
            SizedBox(width: 30),
            buildDigitButton('0'),
            SizedBox(width: 30),
            buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget buildDigitButton(String digit) {
    return SizedBox(
      width: 100,
      height: 60,
      child: FancyButton(
        key: const Key('buildCode'),
        onPressed: () => enterDigit(digit),
        text: digit,
        fontSize: 24,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        borderColor: Colors.lightBlueAccent,
        borderWidth: 4,
      ),
    );
  }

  Widget buildClearButton() {
    return SizedBox(
      width: 100,
      height: 60,
      child:FancyButtonIcon(
        onPressed: deleteAllDigits,
        iconData: Icons.clear,
        iconSize: 24,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        borderColor: Colors.redAccent,
        borderWidth: 4,
      ),

    );
  }

  Widget buildDeleteButton() {
    return SizedBox(
      width: 100,
      height: 60,
      child: FancyButtonIcon(
        onPressed: deleteDigit,
        iconData: Icons.backspace,
        iconSize: 24,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
        borderColor: Colors.redAccent,
        borderWidth: 4,
      ),
    );
  }
}
