import 'package:flutter/material.dart';

class FancyButtonIcon extends StatelessWidget {
  final Key? key;
  final VoidCallback onPressed;
  final IconData iconData;
  final double iconSize;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;

  const FancyButtonIcon({
    this.key,
    required this.onPressed,
    required this.iconData,
    required this.iconSize,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ElevatedButton(
        key: key,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Icon(
          iconData,
          size: iconSize,
        ),
      ),
    );
  }
}
