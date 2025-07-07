import 'package:flutter/material.dart';

class AnswerOptionButton extends StatelessWidget {
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback? onTap;
  final bool showFeedback;

  const AnswerOptionButton({
    Key? key,
    required this.optionLetter,
    required this.optionText,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.onTap,
    this.showFeedback = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFF7C5CFC);
    Color backgroundColor = Colors.white;
    Color textColor = const Color(0xFF7C5CFC);
    Color letterBgColor = const Color(0xFF7C5CFC);
    Color letterTextColor = Colors.white;

    if (showFeedback) {
      if (isCorrect) {
        borderColor = Colors.green;
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        letterBgColor = Colors.white;
        letterTextColor = Colors.green;
      } else if (isIncorrect) {
        borderColor = Colors.red;
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        letterBgColor = Colors.white;
        letterTextColor = Colors.red;
      } else {
        borderColor = Colors.grey.shade300;
        backgroundColor = Colors.grey.shade100!;
        textColor = Colors.grey.shade600;
        letterBgColor = Colors.grey.shade300;
        letterTextColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF7C5CFC);
      textColor = Colors.white;
      letterBgColor = Colors.white;
      letterTextColor = const Color(0xFF7C5CFC);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: letterTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 