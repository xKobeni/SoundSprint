import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../accessibility_manager.dart';
import 'base_game_logic.dart';
import '../../widgets/question_card.dart';
import '../../widgets/answer_option_button.dart';

/// Game logic for image-based questions (image identification)
class ImageGameLogic extends BaseGameLogic {
  bool _isInitialized = false;
  bool _showAnswerFeedback = false;
  String? _selectedAnswer;
  String? _correctAnswer;
  bool _imageLoaded = false;
  bool _imageError = false;

  @override
  String get gameModeName => 'Image Quiz';

  @override
  String get gameModeDescription => 'Look at the image and choose the correct answer from multiple options.';

  @override
  IconData get gameModeIcon => Icons.image;

  @override
  bool supportsQuestionType(String type) {
    return type == 'image';
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isInitialized = true;
    } catch (e) {
      debugPrint('ImageGameLogic initialization error: $e');
    }
  }

  @override
  Future<void> startQuestion(Question question) async {
    if (!supportsQuestionType(question.type ?? '')) {
      throw ArgumentError('Unsupported question type: ${question.type}');
    }

    _imageError = false;
    _imageLoaded = false;
    _showAnswerFeedback = false;
    _selectedAnswer = null;
    _correctAnswer = question.correctAnswer;

    // Simulate image loading time
    await Future.delayed(const Duration(milliseconds: 500));
    _imageLoaded = true;
  }

  @override
  Future<bool> handleAnswer(String? answer, Question question) async {
    final isCorrect = answer == question.correctAnswer;
    
    // Store answer for feedback
    _selectedAnswer = answer;
    _showAnswerFeedback = true;
    
    // Trigger haptic feedback based on answer
    if (answer != null) {
      if (isCorrect) {
        await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.medium);
      } else {
        await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.heavy);
      }
    } else {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.vibrate);
    }

    return isCorrect;
  }

  @override
  Widget buildQuestionWidget(Question question, Function(String?) onAnswer) {
    final options = question.options ?? [];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Who is this person?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildImageSection(question),
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

  Widget _buildImageSection(Question question) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20),
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
            Icons.image,
            size: 48,
            color: const Color(0xFF7C5CFC),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildImageWidget(question),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(Question question) {
    if (_imageError) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Image not available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (!_imageLoaded) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
              ),
              SizedBox(height: 8),
              Text('Loading image...'),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/${question.file}',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          _imageError = true;
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Image not found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  int getTimeLimit(Question question) {
    // Give more time for image analysis
    return 20;
  }

  @override
  void dispose() {
    _isInitialized = false;
  }
} 