import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/sound_question.dart';
import '../game_logic/base_game_logic.dart';
import '../game_logic/game_logic_factory.dart';
import '../question_loader.dart';
import 'stats_manager.dart';
import 'achievement_manager.dart';
import 'daily_points_manager.dart';
import 'difficulty_progression_manager.dart';
import 'notification_manager.dart';

import '../../utils/managers/user_preferences.dart';

/// Central game manager that handles different game modes using modular game logic
class GameManager extends ChangeNotifier {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String? _selectedAnswer;
  late int _timer;
  late int _maxTime;
  List<Map<String, dynamic>> _answerDetails = [];
  DateTime? _gameStartTime;
  int _timeRemaining = 0;
  bool _isPlaying = false;
  String? _errorMessage;
  bool _disposed = false;
  bool _gameFinished = false;
  bool _timeRunOut = false; // Track if time has run out
  
  BaseGameLogic? _currentGameLogic;
  String? _currentGameMode;

  // Getters
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get loading => _loading;
  bool get answered => _answered;
  String? get selectedAnswer => _selectedAnswer;
  int get timer => _timer;
  int get maxTime => _maxTime;
  List<Map<String, dynamic>> get answerDetails => _answerDetails;
  DateTime? get gameStartTime => _gameStartTime;
  int get timeRemaining => _timeRemaining;
  bool get isPlaying => _isPlaying;
  String? get errorMessage => _errorMessage;
  BaseGameLogic? get currentGameLogic => _currentGameLogic;
  String? get currentGameMode => _currentGameMode;
  int get correctCount => _answerDetails.where((a) => a['isCorrect'] == true).length;
  int get incorrectCount => _answerDetails.where((a) => a['isCorrect'] == false).length;
  bool get timeRunOut => _timeRunOut; // Getter for time run out status

  /// Initialize the game manager
  Future<void> initialize() async {
    if (_disposed) return;
    try {
      await GameLogicFactory.initializeAll();
    } catch (e) {
      debugPrint('GameManager initialization error: $e');
    }
  }

  /// Load questions and determine game mode
  Future<void> loadQuestions({
    String? difficulty,
    String? category,
    String? gameMode,
  }) async {
    try {
      if (!_disposed) {
        setState(() {
          _loading = true;
          _errorMessage = null;
        });
      }

      // Load questions
      final questions = await QuestionLoader.loadQuestions(
        difficulty: difficulty,
        category: category,
        mode: gameMode, // Use gameMode as the mode parameter
      );

      // Shuffle questions for randomness
      questions.shuffle();

      if (_disposed) return;

      if (questions.isEmpty) {
        throw Exception('No questions available for the selected criteria');
      }

      // Determine game mode if not specified
      String selectedGameMode = gameMode ?? _determineGameMode(questions);

      // Get the appropriate game logic
      final gameLogic = GameLogicFactory.getGameLogicByModeId(selectedGameMode);

      // Verify compatibility
      if (!GameModeSelector.areQuestionsCompatibleWithMode(
        questions.map((q) => q.toJson()).toList(),
        selectedGameMode,
      )) {
        throw Exception('Questions are not compatible with the selected game mode');
      }

      if (!_disposed) {
        setState(() {
          _questions = questions;
          _currentGameLogic = gameLogic;
          _currentGameMode = selectedGameMode;
          _currentIndex = 0;
          _score = 0;
          _answerDetails = [];
          _gameStartTime = DateTime.now();
          _loading = false;
        });
      }

      // Start the first question
      if (!_disposed) {
        await startCurrentQuestion();
      }
    } catch (e) {
      if (!_disposed) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });
      }
      debugPrint('Error loading questions: $e');
    }
  }

  /// Determine the best game mode for the given questions
  String _determineGameMode(List<Question> questions) {
    if (_disposed) return 'GuessTheSound'; // Default fallback
    final questionData = questions.map((q) => q.toJson()).toList();
    return GameModeSelector.selectGameModeForQuestions(questionData);
  }

  /// Start the current question
  Future<void> startCurrentQuestion([BuildContext? context]) async {
    if (_disposed) return;
    
    if (_currentIndex >= _questions.length) {
      await _finishGame(context);
      return;
    }

    final question = _questions[_currentIndex];
    
    if (!_disposed) {
      setState(() {
        _answered = false;
        _selectedAnswer = null;
        _timer = _currentGameLogic?.getTimeLimit(question) ?? 15;
        _maxTime = _timer;
        _timeRemaining = _timer;
        _isPlaying = true;
        _timeRunOut = false; // Reset time run out flag for new question
      });
    }

    // Start the question using the current game logic
    if (!_disposed) {
      await _currentGameLogic?.startQuestion(question);
    }
    
    // Start the timer
    if (!_disposed) {
      _startTimer();
    }
  }

  /// Start the countdown timer
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_disposed || _answered) return false;
      
      if (!_disposed) {
        setState(() {
          _timeRemaining--;
          _timer = _timeRemaining;
        });
      }
      
      // When timer reaches 0, just stop the timer but don't auto-advance
      if (_timeRemaining <= 0 && !_disposed) {
        setState(() {
          _timer = 0; // Show 0 on timer
          _timeRunOut = true; // Set the flag
        });
        return false; // Stop the timer loop
      }
      return !_disposed;
    });
  }

  /// Handle user answer
  Future<void> handleAnswer(String? answer, [BuildContext? context]) async {
    if (_disposed || _answered || _currentIndex >= _questions.length) return;

    final question = _questions[_currentIndex];
    final isCorrect = await _currentGameLogic?.handleAnswer(answer, question) ?? false;

    if (_disposed) return;

    // Record answer details
    _answerDetails.add({
      'question': question.question ?? 'Unknown',
      'userAnswer': answer,
      'correctAnswer': question.correctAnswer,
      'isCorrect': isCorrect,
      'timeSpent': _maxTime - _timeRemaining,
      'questionType': question.type,
    });

    if (!_disposed) {
      setState(() {
        _answered = true;
        _selectedAnswer = answer;
        if (isCorrect) _score++;
      });
    }

    // Wait a moment to show the result
    await Future.delayed(const Duration(seconds: 2));

    if (_disposed) return;

    // Move to next question
    setState(() {
      _currentIndex++;
    });

    if (!_disposed) {
      await startCurrentQuestion(context);
    }
  }

  /// Build the question widget using the current game logic
  Widget buildQuestionWidget() {
    if (_disposed) {
      return const Center(
        child: Text('Game manager disposed'),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loadQuestions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentIndex >= _questions.length) {
      return const Center(
        child: Text('Game completed!'),
      );
    }

    final question = _questions[_currentIndex];
    return _currentGameLogic?.buildQuestionWidget(question, handleAnswer) ??
        const Center(child: Text('No game logic available'));
  }

  /// Finish the game and save results
  Future<void> _finishGame([BuildContext? context]) async {
    if (_disposed || _gameStartTime == null || _gameFinished) return;
    _gameFinished = true;

    final playTime = DateTime.now().difference(_gameStartTime!);
    
    // Save stats
    await StatsManager.updateGameStats(
      score: _score,
      totalQuestions: _questions.length,
      playtimeSeconds: playTime.inSeconds,
      category: _questions.isNotEmpty ? _questions.first.category : 'unknown',
      difficulty: _questions.isNotEmpty ? _questions.first.difficulty : 'easy',
      gameMode: _currentGameMode ?? 'unknown',
      answers: _answerDetails,
    );

    if (_disposed) return;

    // Calculate mode-specific points
    final modeSpecificPoints = _calculateModeSpecificPoints();

    // Update daily points and global points (ONLY ONCE)
    await DailyPointsManager.addTodayPoints(modeSpecificPoints);
    await UserPreferences().addPoints(modeSpecificPoints);

    // Increment daily games played for daily progress
    await DailyPointsManager.incrementTodayGamesPlayed();

    if (_disposed) return;

    // Update difficulty progression and show level up notification if needed
    final progressionResult = await DifficultyProgressionManager.updateProgression(
      score: _score,
      totalQuestions: _questions.length,
      difficulty: _questions.isNotEmpty ? _questions.first.difficulty : 'easy',
      playtimeSeconds: playTime.inSeconds,
    );

    // Show toast notification for level up
    if (progressionResult['leveledUp'] == true && progressionResult['newLevel'] != null) {
      NotificationManager.showGlobalToast(
        message: 'Level Up! You reached Level ${progressionResult['newLevel']}',
        icon: Icons.emoji_events,
        backgroundColor: Colors.deepPurple[400]!,
        iconColor: Colors.amber,
      );
    }

    // Update achievements after finishing the game
    final newlyUnlocked = await AchievementManager.updateProgress(
        score: _score,
        totalQuestions: _questions.length,
        category: _questions.isNotEmpty ? _questions.first.category : 'unknown',
        difficulty: _questions.isNotEmpty ? _questions.first.difficulty : 'easy',
      currentStreak: (await StatsManager.getAllStats())['currentStreak'] ?? 0,
      mode: _currentGameMode,
      playtimeSeconds: playTime.inSeconds,
      gameStartTime: _gameStartTime,
      );

    // Show toast notification for newly unlocked achievements
    if (newlyUnlocked.isNotEmpty) {
      for (final achievement in newlyUnlocked) {
        NotificationManager.showGlobalToast(
          message: 'Achievement Unlocked: ${achievement.title}',
          icon: Icons.star,
          backgroundColor: Colors.green[600]!,
          iconColor: Colors.orange,
        );
      }
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Get game result data
  GameResult? getGameResult() {
    if (_disposed || _gameStartTime == null) return null;

    final modeSpecificPoints = _calculateModeSpecificPoints();

    return GameResult(
      score: _score,
      totalQuestions: _questions.length,
      answerDetails: _answerDetails,
      playTime: DateTime.now().difference(_gameStartTime!),
      gameMode: _currentGameMode ?? 'unknown',
      modeSpecificPoints: modeSpecificPoints,
    );
  }

  /// Get available game modes
  List<GameModeInfo> getAvailableGameModes() {
    if (_disposed) return [];
    return GameLogicFactory.getAvailableGameModes();
  }

  /// Reset the game
  void reset() {
    if (_disposed) return;
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _answerDetails = [];
      _gameStartTime = null;
      _timeRemaining = 0;
      _isPlaying = false;
      _errorMessage = null;
      _gameFinished = false; // Reset the flag here!
      _timeRunOut = false; // Reset the flag here!
    });
  }

  /// Stop all game activities
  void stopGame() {
    if (_disposed) return;
    
    debugPrint('🛑 GameManager: Stopping all game activities...');
    
    // Stop any ongoing game logic
    _currentGameLogic?.dispose();
    
    // Reset game state
    setState(() {
      _answered = true; // This will stop the timer loop
      _isPlaying = false;
      _timeRemaining = 0;
      _timer = 0;
      _timeRunOut = false; // Ensure it's false when stopping
    });
    
    debugPrint('🛑 GameManager: All game activities stopped');
  }

  /// Set state and notify listeners
  void setState(VoidCallback fn) {
    if (_disposed) return;
    fn();
    notifyListeners();
  }

  /// Check if the manager is still active
  bool get mounted => !_disposed;

  /// Dispose resources
  @override
  void dispose() {
    _disposed = true;
    GameLogicFactory.disposeAll();
    super.dispose();
  }

  /// Calculate mode-specific points based on game mode and performance
  int _calculateModeSpecificPoints() {
    if (_currentGameMode == null) return 0;
    final basePoints = _score * 1; // 1 point per correct answer
    int modeBonus = 0;
    
    // Debug logging
    debugPrint('=== POINT CALCULATION DEBUG ===');
    debugPrint('Game Mode: $_currentGameMode');
    debugPrint('Score: $_score, Total Questions: ${_questions.length}');
    debugPrint('Base Points: $basePoints');
    
    switch (_currentGameMode) {
      case 'GuessTheSound':
        if (_score >= 2) modeBonus = 1;
        debugPrint('GuessTheSound Mode Bonus: $modeBonus');
        break;
      case 'GuessTheMusic':
        modeBonus = _score ~/ 3; // +1 for every 3 correct
        debugPrint('GuessTheMusic Mode Bonus: $modeBonus');
        break;
      case 'TrueOrFalse':
      case 'Vocabulary':
      case 'GuessTheImage':
        modeBonus = 0;
        debugPrint('${_currentGameMode} Mode Bonus: $modeBonus');
        break;
      default:
        modeBonus = 0;
        debugPrint('Default Mode Bonus: $modeBonus');
    }
    
    // Add perfect score bonus
    int perfectScoreBonus = 0;
    if (_score == _questions.length && _score > 0) {
      perfectScoreBonus = 2;
      debugPrint('Perfect Score Bonus: $perfectScoreBonus');
    }
    
    final totalPoints = basePoints + modeBonus + perfectScoreBonus;
    debugPrint('Total Points: $totalPoints (Base: $basePoints + Mode: $modeBonus + Perfect: $perfectScoreBonus)');
    debugPrint('=== END POINT CALCULATION DEBUG ===');
    
    return totalPoints;
  }

  /// Get current game mode name
  String get currentGameModeName {
    if (_currentGameMode == null) return 'Unknown';
    switch (_currentGameMode) {
      case 'GuessTheSound':
        return 'Sound Quiz';
      case 'GuessTheMusic':
        return 'Music Quiz';
      case 'TrueOrFalse':
        return 'True/False';
      case 'Vocabulary':
        return 'Vocabulary';
      case 'GuessTheImage':
        return 'Image Quiz';
      default:
        return 'Quiz';
    }
  }
} 