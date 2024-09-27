//import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../widgets/parking_number_button.dart';
//import 'package:image/image.dart' as img;


class TestImageScreen extends StatefulWidget {
  const TestImageScreen({super.key});

  @override
  TestImageScreenState createState() => TestImageScreenState();
}

class TestImageScreenState extends State<TestImageScreen> {

  int selectedNumber = 0;

  void _selectNumber(int number) {
    setState(() {
      selectedNumber = number;
    });
  }
  List<ParkingNumberButton> generateNumberButtons({required int endNumber, required double startLeftRatio,required double incrementLeftRatio, required double startTopRatio, required double incrementTopRatio, required double rotationParam, required int startNumber}) {
    final buttons = <ParkingNumberButton>[];

    for (int i = startNumber; i <= endNumber; i++) {
      buttons.add(
        ParkingNumberButton(
          leftRatio: startLeftRatio - (incrementLeftRatio * (i-startNumber - 1)), // Adjust leftRatio based on button index
          topRatio: startTopRatio - (incrementTopRatio * (i-startNumber - 1)),
          number: i,
          selectedNumber: selectedNumber,
          rotation: rotationParam,
          onTap: () => _selectNumber(i),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Number Selection')),
      body: Column(
        children: [
          Stack(
            children: [
              // Image.asset('images/p1.png',), // Replace with your image asset
              SizedBox(
                width: screenSize.width,
                height: screenSize.height *0.67,
                child: const ColoredBox(
                  color: Colors.white54,
                ),
              ),
              ...generateNumberButtons(
                endNumber:13, startLeftRatio: 0.855, incrementLeftRatio: 0.06, startTopRatio: 0.55, incrementTopRatio: 0, rotationParam: 0.05, startNumber: 1,
              ),
              ...generateNumberButtons(
                endNumber:17, startLeftRatio: 0.08, incrementLeftRatio: 0.015, startTopRatio: 0.49, incrementTopRatio: 0.04, rotationParam: 0.9, startNumber: 14,
              ),
              ParkingNumberButton(leftRatio: 0.07, topRatio: 0.27, number: 18, selectedNumber: selectedNumber, rotation: 1.1, onTap: () => _selectNumber(18)),
              ...generateNumberButtons(
                endNumber:28, startLeftRatio: 0.78, incrementLeftRatio: 0.06, startTopRatio: 0.43, incrementTopRatio: 0, rotationParam: 0.05, startNumber: 19,
              ),
              ParkingNumberButton(leftRatio: 0.24, topRatio: 0.43, number: 58, selectedNumber: selectedNumber, rotation: 0, onTap: () => _selectNumber(58)),
              ...generateNumberButtons(
                endNumber:37, startLeftRatio: 0.55, incrementLeftRatio: 0.06, startTopRatio: 0.36, incrementTopRatio: 0, rotationParam: 0.05, startNumber: 34,
              ),
              ParkingNumberButton(leftRatio: 0.34, topRatio: 0.375, number: 38, selectedNumber: selectedNumber, rotation: 1.5, onTap: () => _selectNumber(38)),
              ...generateNumberButtons(
                endNumber:33, startLeftRatio: 0.85, incrementLeftRatio: 0.06, startTopRatio: 0.3, incrementTopRatio: 0, rotationParam: 0, startNumber: 29,
              ),
              ...generateNumberButtons(
                endNumber:50, startLeftRatio: 0.8, incrementLeftRatio: 0.06, startTopRatio: 0.1, incrementTopRatio: 0, rotationParam: 0, startNumber: 44,
              ),
              ...generateNumberButtons(
                endNumber:57, startLeftRatio: 0.8, incrementLeftRatio: 0.06, startTopRatio: 0.17, incrementTopRatio: 0, rotationParam: 0, startNumber: 51,
              ),
              ParkingNumberButton(leftRatio: 0.2, topRatio: 0.23, number: 39, selectedNumber: selectedNumber, rotation: 1.1, onTap: () => _selectNumber(39)),
              ParkingNumberButton(leftRatio: 0.285, topRatio: 0.2, number: 40, selectedNumber: selectedNumber, rotation: 1.1, onTap: () => _selectNumber(40)),
              ParkingNumberButton(leftRatio: 0.36, topRatio: 0.175, number: 41, selectedNumber: selectedNumber, rotation: 1.1, onTap: () => _selectNumber(41)),
              ParkingNumberButton(leftRatio: 0.36, topRatio: 0.1, number: 42, selectedNumber: selectedNumber, rotation: -0.5, onTap: () => _selectNumber(42)),

            ],
          ),
          Text(
            selectedNumber.toString(),
            style: TextStyle(fontSize: screenSize.height * 0.05),
          ),
        ],
      ),
    );
  }
}
