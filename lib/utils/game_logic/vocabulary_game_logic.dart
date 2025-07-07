import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../accessibility_manager.dart';
import 'base_game_logic.dart';
import '../../widgets/question_card.dart';
import '../../widgets/answer_option_button.dart';

/// Game logic for vocabulary questions
class VocabularyGameLogic extends BaseGameLogic {
  bool _isInitialized = false;
  bool _showAnswerFeedback = false;
  String? _selectedAnswer;
  String? _correctAnswer;

  @override
  String get gameModeName => 'Vocabulary Quiz';

  @override
  String get gameModeDescription => 'Test your knowledge with vocabulary and word-based questions.';

  @override
  IconData get gameModeIcon => Icons.book;

  @override
  bool supportsQuestionType(String type) {
    return type == 'vocabulary';
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // No special initialization needed for vocabulary
      _isInitialized = true;
    } catch (e) {
      debugPrint('VocabularyGameLogic initialization error: $e');
    }
  }

  @override
  Future<void> startQuestion(Question question) async {
    if (!supportsQuestionType(question.type ?? '')) {
      throw ArgumentError('Unsupported question type: ${question.type}');
    }

    _showAnswerFeedback = false;
    _selectedAnswer = null;
    _correctAnswer = question.correctAnswer;

    // No special setup needed for vocabulary questions
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> handleAnswer(String? answer, Question question) async {
    if (answer == null) return false;
    
    final isCorrect = answer == question.correctAnswer;
    
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
    final options = question.options ?? [];
    return Column(
      children: [
        QuestionCard(
          questionText: question.question ?? 'Vocabulary Question',
        ),
        const SizedBox(height: 24),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedAnswer == option;
          final isCorrect = _showAnswerFeedback && option == _correctAnswer;
          final isIncorrect = _showAnswerFeedback && isSelected && option != _correctAnswer;
          return AnswerOptionButton(
            optionLetter: String.fromCharCode(65 + index),
            optionText: option,
            isSelected: isSelected,
            isCorrect: isCorrect,
            isIncorrect: isIncorrect,
            showFeedback: _showAnswerFeedback,
            onTap: _showAnswerFeedback ? null : () => onAnswer(option),
          );
        }).toList(),
      ],
    );
  }

  @override
  int getTimeLimit(Question question) {
    return 20; // More time for vocabulary questions as they require reading
  }

  @override
  void dispose() {
    // No resources to dispose for vocabulary logic
  }
} 