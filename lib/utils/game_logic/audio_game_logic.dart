import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/sound_question.dart';
import '../audio_manager.dart';
import '../accessibility_manager.dart';
import 'base_game_logic.dart';

/// Game logic for audio-based questions (music and sound guessing)
class AudioGameLogic extends BaseGameLogic {
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _audioError = false;
  bool _showAnswerFeedback = false;
  String? _selectedAnswer;
  String? _correctAnswer;
  final String type;

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
    _isPlaying = false;
    _showAnswerFeedback = false;
    _selectedAnswer = null;
    _correctAnswer = question.correctAnswer;

    try {
      _isPlaying = true;
      
      // Play the audio using AudioManager
      final success = await AudioManager().playAudio(
        fileName: question.file ?? '',
        type: question.type ?? 'sound',
        clipStart: question.clipStart,
        clipEnd: question.clipEnd,
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

      _isPlaying = false;
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _audioError = true;
      _isPlaying = false;
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Audio player section
          _buildAudioPlayerSection(question),
          const SizedBox(height: 30),
          
          // Question display
          _buildQuestionDisplay(question),
          const SizedBox(height: 30),
          
          // Answer options
          _buildAnswerOptions(question, onAnswer),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerSection(Question question) {
    return Container(
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
          else if (_isPlaying)
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
  }

  Widget _buildQuestionDisplay(Question question) {
    return Container(
      width: double.infinity,
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
          Text(
            'What did you hear?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          if (question.question != null) ...[
            const SizedBox(height: 12),
            Text(
              question.question!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
        IconData? icon;
        
        if (_showAnswerFeedback) {
          if (option == _correctAnswer) {
            // Correct answer - always show in green
            backgroundColor = Colors.green;
            foregroundColor = Colors.white;
            borderColor = Colors.green;
            icon = Icons.check_circle;
          } else if (option == _selectedAnswer && option != _correctAnswer) {
            // Wrong selected answer - show in red
            backgroundColor = Colors.red;
            foregroundColor = Colors.white;
            borderColor = Colors.red;
            icon = Icons.cancel;
          } else {
            // Other options - show in gray
            backgroundColor = Colors.grey.shade200;
            foregroundColor = Colors.grey.shade600;
            borderColor = Colors.grey.shade400;
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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