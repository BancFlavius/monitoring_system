import 'package:flutter/material.dart';

class FancyButton extends StatelessWidget {
  final Key? key;
  final VoidCallback onPressed;
  final String text;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;

  const FancyButton({
    this.key,
    required this.onPressed,
    required this.text,
    required this.fontSize,
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
            spreadRadius: 4,
            blurRadius: 2,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        key: key,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    );
  }
}
