import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../managers/accessibility_manager.dart';
import 'base_game_logic.dart';
import '../../widgets/question_card.dart';

/// Game logic for true/false questions
class TrueFalseGameLogic extends BaseGameLogic {
  bool _isInitialized = false;
  bool _showAnswerFeedback = false;
  String? _selectedAnswer;
  bool? _correctAnswer;

  @override
  String get gameModeName => 'True or False';

  @override
  String get gameModeDescription => 'Read statements and determine if they are true or false.';

  @override
  IconData get gameModeIcon => Icons.check_circle_outline;

  @override
  bool supportsQuestionType(String type) {
    return type == 'truefalse';
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // No special initialization needed for true/false
      _isInitialized = true;
    } catch (e) {
      debugPrint('TrueFalseGameLogic initialization error: $e');
    }
  }

  @override
  Future<void> startQuestion(Question question) async {
    if (!supportsQuestionType(question.type ?? '')) {
      throw ArgumentError('Unsupported question type: ${question.type}');
    }

    _showAnswerFeedback = false;
    _selectedAnswer = null;
    _correctAnswer = question.answer;

    // No special setup needed for true/false questions
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> handleAnswer(String? answer, Question question) async {
    if (answer == null) return false;
    
    final userAnswer = answer.toLowerCase() == 'true';
    final correctAnswer = question.answer ?? false;
    final isCorrect = userAnswer == correctAnswer;
    
    // Store answer for feedback
    _selectedAnswer = answer;
    _showAnswerFeedback = true;
    
    // Trigger haptic feedback based on answer
    if (isCorrect) {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.medium);
    } else {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.heavy);
    }

    return isCorrect;
  }

  @override
  Widget buildQuestionWidget(Question question, Function(String?) onAnswer) {
    final isTrueSelected = _selectedAnswer == 'true';
    final isFalseSelected = _selectedAnswer == 'false';
    final showFeedback = _showAnswerFeedback;
    final isCorrectTrue = showFeedback && (_correctAnswer == true);
    final isCorrectFalse = showFeedback && (_correctAnswer == false);
    final isIncorrectTrue = showFeedback && isTrueSelected && (_correctAnswer != true);
    final isIncorrectFalse = showFeedback && isFalseSelected && (_correctAnswer != false);

    Color getTrueBorder() {
      if (showFeedback) {
        if (isCorrectTrue) return Colors.green;
        if (isIncorrectTrue) return Colors.red;
        return Colors.grey.shade300;
      }
      if (isTrueSelected) return Colors.green;
      return Colors.green;
    }
    Color getFalseBorder() {
      if (showFeedback) {
        if (isCorrectFalse) return Colors.green;
        if (isIncorrectFalse) return Colors.red;
        return Colors.grey.shade300;
      }
      if (isFalseSelected) return Colors.red;
      return Colors.red;
    }
    Color getTrueFill() {
      if (showFeedback) {
        if (isCorrectTrue) return Colors.green;
        if (isIncorrectTrue) return Colors.red;
        return Colors.white;
      }
      if (isTrueSelected) return Colors.green;
      return Colors.white;
    }
    Color getFalseFill() {
      if (showFeedback) {
        if (isCorrectFalse) return Colors.green;
        if (isIncorrectFalse) return Colors.red;
        return Colors.white;
      }
      if (isFalseSelected) return Colors.red;
      return Colors.white;
    }
    Color getTrueText() {
      if (showFeedback) {
        if (isCorrectTrue || isIncorrectTrue) return Colors.white;
        return Colors.green;
      }
      if (isTrueSelected) return Colors.white;
      return Colors.green;
    }
    Color getFalseText() {
      if (showFeedback) {
        if (isCorrectFalse || isIncorrectFalse) return Colors.white;
        return Colors.red;
      }
      if (isFalseSelected) return Colors.white;
      return Colors.red;
    }

    return Column(
      children: [
        QuestionCard(
          questionText: question.question ?? 'True or False?',
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: showFeedback ? null : () => onAnswer('true'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: getTrueFill(),
                  side: BorderSide(color: getTrueBorder(), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'TRUE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getTrueText(),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: showFeedback ? null : () => onAnswer('false'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: getFalseFill(),
                  side: BorderSide(color: getFalseBorder(), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'FALSE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getFalseText(),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTrueButtonColor() {
    if (!_showAnswerFeedback) return Colors.green;
    return _correctAnswer == true ? Colors.green : Colors.grey;
  }

  Color _getFalseButtonColor() {
    if (!_showAnswerFeedback) return Colors.red;
    return _correctAnswer == false ? Colors.red : Colors.grey;
  }

  IconData _getTrueButtonIcon() {
    if (!_showAnswerFeedback) return Icons.check_circle;
    return _correctAnswer == true ? Icons.check_circle : Icons.cancel;
  }

  IconData _getFalseButtonIcon() {
    if (!_showAnswerFeedback) return Icons.cancel;
    return _correctAnswer == false ? Icons.check_circle : Icons.cancel;
  }

  @override
  int getTimeLimit(Question question) {
    return 15; // Standard time for true/false questions
  }

  @override
  void dispose() {
    // No resources to dispose for true/false logic
  }
} 