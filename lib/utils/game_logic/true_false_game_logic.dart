import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../accessibility_manager.dart';
import 'base_game_logic.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Question display
          _buildQuestionDisplay(question),
          const SizedBox(height: 40),
          
          // True/False buttons
          _buildTrueFalseButtons(onAnswer),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz,
            size: 48,
            color: const Color(0xFF7C5CFC),
          ),
          const SizedBox(height: 20),
          Text(
            'True or False?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 20),
          if (question.question != null)
            Text(
              question.question!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseButtons(Function(String?) onAnswer) {
    return Row(
      children: [
        // True Button
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _showAnswerFeedback ? null : () => onAnswer('true'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTrueButtonColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              child: Column(
                children: [
                  Icon(
                    _getTrueButtonIcon(),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TRUE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // False Button
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: _showAnswerFeedback ? null : () => onAnswer('false'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getFalseButtonColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              child: Column(
                children: [
                  Icon(
                    _getFalseButtonIcon(),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FALSE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
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