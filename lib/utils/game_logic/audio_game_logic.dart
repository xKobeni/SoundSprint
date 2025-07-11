import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/sound_question.dart';
import '../managers/audio_manager.dart';
import '../managers/accessibility_manager.dart';
import 'base_game_logic.dart';
import '../../widgets/question_card.dart';
import '../../widgets/answer_option_button.dart';

/// Game logic for audio-based questions (music and sound guessing)
class AudioGameLogic extends BaseGameLogic {
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  bool _audioError = false;
  bool _showAnswerFeedback = false;
  String? _selectedAnswer;
  String? _correctAnswer;
  final String type;

  // Store shuffled options per question hashCode
  final Map<int, List<String>> _shuffledOptions = {};

  AudioGameLogic({this.type = 'sound'});

  @override
  String get gameModeName => type == 'music' ? 'Music Quiz' : 'Sound Quiz';

  @override
  String get gameModeDescription => type == 'music'
      ? 'Listen to music clips and choose the correct answer from multiple options.'
      : 'Listen to sounds and choose the correct answer from multiple options.';

  @override
  IconData get gameModeIcon => type == 'music' ? Icons.music_note : Icons.volume_up;

  @override
  bool supportsQuestionType(String type) {
    return type == 'sound' || type == 'music';
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _audioPlayer = AudioPlayer();
      await AudioManager().initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AudioGameLogic initialization error: $e');
    }
  }

  @override
  Future<void> startQuestion(Question question) async {
    if (!supportsQuestionType(question.type ?? '')) {
      throw ArgumentError('Unsupported question type: ${question.type}');
    }

    _audioError = false;
    _isPlaying.value = false;
    _showAnswerFeedback = false;
    _selectedAnswer = null;
    _correctAnswer = question.correctAnswer;

    // Shuffle options only once per question
    final options = List<String>.from(question.options ?? []);
    options.shuffle();
    _shuffledOptions[question.hashCode] = options;

    try {
      // Stop any currently playing audio before starting new question
      await AudioManager().stopAll();
      _isPlaying.value = true;
      
      // Play the audio using AudioManager
      final success = await AudioManager().playAudio(
        fileName: question.file ?? '',
        type: question.type ?? 'sound',
        clipStart: question.clipStart,
        clipEnd: question.clipEnd,
        category: question.category,
      );

      if (!success) {
        _audioError = true;
        debugPrint('Failed to play audio: ${question.file}');
      }

      // Wait for audio to finish or show playing state
      if (question.type == 'music' && question.clipStart != null && question.clipEnd != null) {
        await Future.delayed(Duration(seconds: question.clipEnd! - question.clipStart!));
      } else {
        await Future.delayed(const Duration(seconds: 3));
      }

      _isPlaying.value = false;
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _audioError = true;
      _isPlaying.value = false;
    }
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
    final options = _shuffledOptions[question.hashCode] ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio player section at the top
        _buildAudioPlayerSection(question),
        const SizedBox(height: 16),
        // Question (if any)
        if ((question.question ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: QuestionCard(
              questionText: question.question!,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            ),
          ),
        // Answer options (no Expanded here)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        ),
      ],
    );
  }

  Widget _buildAudioPlayerSection(Question question) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPlaying,
      builder: (context, isPlaying, child) {
        return Container(
          width: double.infinity,
          height: 180,
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
                type == 'music' ? Icons.music_note : Icons.volume_up,
                size: 48,
                color: const Color(0xFF7C5CFC),
              ),
              const SizedBox(height: 16),
              Text(
                type == 'music' ? 'Listen to the Music' : 'Listen to the Sound',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C5CFC),
                ),
              ),
              const SizedBox(height: 8),
              if (_audioError)
                const Text(
                  'Audio not available',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                )
              else if (isPlaying)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Playing...'),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  int getTimeLimit(Question question) {
    switch (question.type) {
      case 'music':
        return 30; // Longer time for music questions
      case 'sound':
        return 10; // Shorter time for sound questions
      default:
        return 15;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
} 