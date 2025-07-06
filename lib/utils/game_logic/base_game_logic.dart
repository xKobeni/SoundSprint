import 'package:flutter/material.dart';
import '../../models/sound_question.dart';

/// Base interface for all game logic implementations
abstract class BaseGameLogic {
  /// Initialize the game logic
  Future<void> initialize();
  
  /// Start a new question
  Future<void> startQuestion(Question question);
  
  /// Handle user answer
  Future<bool> handleAnswer(String? answer, Question question);
  
  /// Get the UI widget for the current question
  Widget buildQuestionWidget(Question question, Function(String?) onAnswer);
  
  /// Get the time limit for the current question type
  int getTimeLimit(Question question);
  
  /// Check if the question type is supported by this logic
  bool supportsQuestionType(String type);
  
  /// Get the game mode name
  String get gameModeName;
  
  /// Get the game mode description
  String get gameModeDescription;
  
  /// Get the game mode icon
  IconData get gameModeIcon;
  
  /// Clean up resources
  void dispose();
}

/// Game state for tracking current question progress
class GameState {
  final int currentIndex;
  final int totalQuestions;
  final int score;
  final bool isAnswered;
  final String? selectedAnswer;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? gameStartTime;
  final int timeRemaining;
  final bool isPlaying;

  const GameState({
    required this.currentIndex,
    required this.totalQuestions,
    required this.score,
    required this.isAnswered,
    this.selectedAnswer,
    required this.isLoading,
    this.errorMessage,
    this.gameStartTime,
    required this.timeRemaining,
    required this.isPlaying,
  });

  GameState copyWith({
    int? currentIndex,
    int? totalQuestions,
    int? score,
    bool? isAnswered,
    String? selectedAnswer,
    bool? isLoading,
    String? errorMessage,
    DateTime? gameStartTime,
    int? timeRemaining,
    bool? isPlaying,
  }) {
    return GameState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      isAnswered: isAnswered ?? this.isAnswered,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

/// Game result data
class GameResult {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> answerDetails;
  final Duration playTime;
  final String gameMode;

  const GameResult({
    required this.score,
    required this.totalQuestions,
    required this.answerDetails,
    required this.playTime,
    required this.gameMode,
  });

  double get accuracy => totalQuestions > 0 ? score / totalQuestions : 0.0;
  int get percentage => (accuracy * 100).round();
} 