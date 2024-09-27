import 'package:flutter/material.dart';

class ParkingNumberButton extends StatelessWidget {
  final double leftRatio;
  final double topRatio;
  final int number;
  final int selectedNumber;
  final double rotation;
  final VoidCallback onTap;

  const ParkingNumberButton({
    super.key,
    required this.leftRatio,
    required this.topRatio,
    required this.number,
    required this.selectedNumber,
    required this.rotation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: screenSize.width * leftRatio,
      top: screenSize.height * topRatio,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: screenSize.width * 0.06,
            height: screenSize.height * 0.07,
            decoration: BoxDecoration(
                color: selectedNumber == number ? Colors.yellow.shade700 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(screenSize.width * 0.01),
                border: Border.all(
                  color: Colors.black87,
                )
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}