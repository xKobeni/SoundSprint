import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../accessibility_manager.dart';
import 'base_game_logic.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Question display
          _buildQuestionDisplay(question),
          const SizedBox(height: 30),
          // Answer options
          _buildAnswerOptions(question, onAnswer),
          // Answer feedback removed
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
            Icons.book,
            size: 48,
            color: const Color(0xFF7C5CFC),
          ),
          const SizedBox(height: 20),
          Text(
            'Vocabulary Question',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 20),
          if (question.question != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C5CFC), width: 1),
              ),
              child: Text(
                question.question!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question, Function(String?) onAnswer) {
    final options = question.options ?? [];
    
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        // Determine button styling based on answer feedback
        Color backgroundColor = Colors.white;
        Color foregroundColor = const Color(0xFF7C5CFC);
        Color borderColor = const Color(0xFF7C5CFC);
        Color letterBackgroundColor = const Color(0xFF7C5CFC);
        Color letterTextColor = Colors.white;
        IconData? icon;
        
        if (_showAnswerFeedback) {
          if (option == _correctAnswer) {
            // Correct answer - always show in green
            backgroundColor = Colors.green;
            foregroundColor = Colors.white;
            borderColor = Colors.green;
            letterBackgroundColor = Colors.white;
            letterTextColor = Colors.green;
            icon = Icons.check_circle;
          } else if (option == _selectedAnswer && option != _correctAnswer) {
            // Wrong selected answer - show in red
            backgroundColor = Colors.red;
            foregroundColor = Colors.white;
            borderColor = Colors.red;
            letterBackgroundColor = Colors.white;
            letterTextColor = Colors.red;
            icon = Icons.cancel;
          } else {
            // Other options - show in gray
            backgroundColor = Colors.grey.shade200;
            foregroundColor = Colors.grey.shade600;
            borderColor = Colors.grey.shade400;
            letterBackgroundColor = Colors.grey.shade400;
            letterTextColor = Colors.white;
          }
        }
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: _showAnswerFeedback ? null : () => onAnswer(option),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              elevation: 4,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D...
                      style: TextStyle(
                        color: letterTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (icon != null) ...[
                        Icon(icon, size: 20),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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