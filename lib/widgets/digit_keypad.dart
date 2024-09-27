import 'package:flutter/material.dart';

import 'fancy_button.dart';
import 'fancy_button_icon.dart';

typedef DigitEnteredCallback = void Function({required BuildContext context,required String digits});

class DigitKeypad extends StatefulWidget {
  final DigitEnteredCallback  onDigitEntered;
  final Size screenSize;
  final BuildContext buildContext;

  static String enteredDigits = '';
  const DigitKeypad({super.key, required this.onDigitEntered, required this.screenSize, required this.buildContext});

  @override
  DigitKeypadState createState() => DigitKeypadState();
}

class DigitKeypadState extends State<DigitKeypad> {

  void enterDigit(String digit) {
    setState(() {
      if (DigitKeypad.enteredDigits.length < 4) {
        DigitKeypad.enteredDigits += digit;
      }
    });
    widget.onDigitEntered(digits: DigitKeypad.enteredDigits,context: widget.buildContext);
  }

  void deleteDigit() {
    setState(() {
      if (DigitKeypad.enteredDigits.isNotEmpty) {
        DigitKeypad.enteredDigits = DigitKeypad.enteredDigits
            .substring(0, DigitKeypad.enteredDigits.length - 1);
      }
    });
    widget.onDigitEntered(digits: DigitKeypad.enteredDigits,context: widget.buildContext);
  }

  void deleteAllDigits() {
    setState(() {
      DigitKeypad.enteredDigits = '';
    });
    widget.onDigitEntered(digits: DigitKeypad.enteredDigits,context: widget.buildContext);
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
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('2'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('3'),
          ],
        ),
        SizedBox(
          height: widget.screenSize.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('4'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('5'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('6'),
          ],
        ),
        SizedBox(
          height: widget.screenSize.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDigitButton('7'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('8'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('9'),
          ],
        ),
        SizedBox(
          height: widget.screenSize.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildClearButton(),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDigitButton('0'),
            SizedBox(width: widget.screenSize.width * 0.02,),
            buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget buildDigitButton(String digit) {
    return SizedBox(
      width: widget.screenSize.width * 0.27,
      height: widget.screenSize.height * 0.11,
      child: FancyButton(
        key: const Key('buildCode'),
        onPressed: () => enterDigit(digit),
        text: digit,
        fontSize: widget.screenSize.width * 0.11,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        borderColor: Colors.lightBlueAccent,
        borderWidth: 4,
      ),
      // child: ElevatedButton(
      //   onPressed: () => enterDigit(digit),
      //   child: Text(
      //     digit,
      //     style: TextStyle(fontSize: widget.screenSize.width * 0.15),
      //     key: const Key('buildCode'),
      //   ),
      // ),
    );
  }

  Widget buildClearButton() {
    return SizedBox(
      width: widget.screenSize.width * 0.27,
      height: widget.screenSize.height * 0.11,
      child:FancyButtonIcon(
        onPressed: deleteAllDigits,
        iconData: Icons.clear,
        iconSize: widget.screenSize.width * 0.12,
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
      //     size: widget.screenSize.width * 0.17,
      //   ),
      //
      // ),
    );
  }

  Widget buildDeleteButton() {
    return SizedBox(
      width: widget.screenSize.width * 0.27,
      height: widget.screenSize.height * 0.11,
      child: FancyButtonIcon(
        onPressed: deleteDigit,
        iconData: Icons.backspace,
        iconSize: widget.screenSize.width * 0.12,
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
      //     size: widget.screenSize.width * 0.17,
      //   ),
      // ),
    );
  }
}
