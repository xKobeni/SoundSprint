import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound_question.dart';
import '../utils/question_loader.dart';
import '../utils/stats_manager.dart';
import '../utils/audio_manager.dart';
import '../utils/accessibility_manager.dart';
import '../utils/achievement_manager.dart';
import '../utils/daily_challenge_manager.dart';
import '../utils/daily_points_manager.dart';
import '../utils/difficulty_progression_manager.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/top_notification.dart';
import '../utils/user_preferences.dart';

class GamePage extends StatefulWidget {
  final String? difficulty;
  final int? timeLimit;
  final String? category;

  const GamePage({
    Key? key, 
    this.difficulty, 
    this.timeLimit, 
    this.category,
  }) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String? _selectedAnswer;
  late AudioPlayer _audioPlayer;
  late int _timer;
  late int _maxTime;
  List<Map<String, dynamic>> _answerDetails = [];
  DateTime? _gameStartTime;
  double _volume = 0.5;
  bool _audioError = false;
  bool _isPlaying = false;
  bool _isMuted = false;

  final Color primaryColor = const Color(0xFF7C5CFC);
  final Color accentColor = const Color(0xFFFFB6B6);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadSettings();
    _loadQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // Load volume setting from SettingsProvider
    setState(() {
      _volume = 0.5; // Default volume
    });
    await _audioPlayer.setVolume(_volume);
  }

  Future<void> _loadQuestions() async {
    try {
      List<Question> questions;
      
      // Load regular questions
      questions = await QuestionLoader.loadQuestions(
        difficulty: widget.difficulty,
        category: widget.category,
      );
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
          if (_questions.isNotEmpty) {
            _gameStartTime = DateTime.now();
            _startQuestion();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _showErrorDialog('Failed to load questions: $e');
      }
    }
  }

  void _startQuestion() async {
    if (_currentIndex >= _questions.length) {
      _goToResultPage();
      return;
    }
    
    setState(() {
      _answered = false;
      _selectedAnswer = null;
      _audioError = false;
      _timer = widget.timeLimit ?? (_questions[_currentIndex].type == 'music' ? 30 : 10);
      _maxTime = _timer;
    });
    await _playAudio();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _answered) return false;
      setState(() {
        _timer--;
      });
      
      // Trigger haptic feedback for low time
      if (_timer <= 3 && _timer > 0) {
        await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.light);
      }
      
      if (_timer <= 0) {
        _onAnswer(null);
        return false;
      }
      return true;
    });
  }

  Future<void> _playAudio() async {
    try {
      final q = _questions[_currentIndex];
      
      setState(() {
        _isPlaying = true;
        _audioError = false;
      });

      // Use the new AudioManager
      final success = await AudioManager().playAudio(
        fileName: q.file ?? '',
        type: q.type ?? 'sound',
        clipStart: q.clipStart,
        clipEnd: q.clipEnd,
      );

      if (!success) {
        setState(() {
          _audioError = true;
        });
      }

      // Wait for audio to finish or show playing state
      if (q.type == 'music' && q.clipStart != null && q.clipEnd != null) {
        await Future.delayed(Duration(seconds: q.clipEnd! - q.clipStart!));
      } else {
        await Future.delayed(const Duration(seconds: 3));
      }

      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _audioError = true;
        _isPlaying = false;
      });
    }
  }

  void _onAnswer(String? answer) async {
    final q = _questions[_currentIndex];
    final isCorrect = answer == q.correctAnswer;
    
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

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        _score++;
      }
      _answerDetails.add({
        'question': q.type == 'sound' ? 'Sound: ${q.file}' : 'Music: ${q.file}',
        'userAnswer': answer,
        'correctAnswer': q.correctAnswer,
        'category': q.category,
        'difficulty': q.difficulty,
      });
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentIndex++;
      });
      _startQuestion();
    });
  }

  void _goToResultPage() async {
    // Calculate playtime
    final playtimeSeconds = _gameStartTime != null 
        ? DateTime.now().difference(_gameStartTime!).inSeconds 
        : 0;
    
    // Get current streak for achievements and challenges
    final stats = await StatsManager.getAllStats();
    final currentStreak = stats['currentStreak'] ?? 0;
    
    Map<String, dynamic>? progression;
    
    // Update regular game stats
    await StatsManager.updateGameStats(
      score: _score,
      totalQuestions: _questions.length,
      playtimeSeconds: playtimeSeconds,
      category: widget.category ?? 'Mixed',
      difficulty: widget.difficulty ?? 'Medium',
      answers: _answerDetails,
    );
    
    // Update achievements
    final newAchievements = await AchievementManager.updateProgress(
      score: _score,
      totalQuestions: _questions.length,
      category: widget.category ?? 'Mixed',
      difficulty: widget.difficulty ?? 'Medium',
      currentStreak: currentStreak,
      mode: _questions.isNotEmpty ? _questions[0].mode : null,
      playtimeSeconds: playtimeSeconds,
      gameStartTime: _gameStartTime,
    );
    
    // Update daily challenges
    final completedChallenges = await DailyChallengeManager.updateProgress(
      score: _score,
      totalQuestions: _questions.length,
      category: widget.category ?? 'Mixed',
      difficulty: widget.difficulty ?? 'Medium',
      currentStreak: currentStreak,
    );
    
    // Update difficulty progression
    progression = await DifficultyProgressionManager.updateProgression(
      score: _score,
      totalQuestions: _questions.length,
      difficulty: widget.difficulty ?? 'Medium',
      playtimeSeconds: playtimeSeconds,
    );

    // Award points based on score and difficulty
    int pointsEarned = _score * _getDifficultyMultiplier(widget.difficulty ?? 'Medium');
    await UserPreferences().addPoints(pointsEarned);
    
    // Also add points to daily progress
    await DailyPointsManager.addTodayPoints(pointsEarned);
    
    TopNotification.show(
      context,
      message: 'You earned $pointsEarned points!',
      icon: Icons.stars,
      iconColor: Color(0xFFFFD700),
      points: pointsEarned,
      alignment: Alignment.topRight,
    );
    
    // Show achievement notifications
    if (newAchievements.isNotEmpty) {
      _showAchievementNotifications(newAchievements);
    }
    
    // Show challenge completion notifications and add daily points
    if (completedChallenges.isNotEmpty) {
      _showChallengeNotifications(completedChallenges);
      
      // Add points to daily progress for completed challenges
      int dailyPointsEarned = 0;
      for (final challenge in completedChallenges) {
        if (challenge.rewardAmount != null && challenge.rewardAmount! > 0) {
          dailyPointsEarned += challenge.rewardAmount!;
        }
      }
      
      if (dailyPointsEarned > 0) {
        await DailyPointsManager.addTodayPoints(dailyPointsEarned);
      }
    }
    
    // Show level up notification
    if (progression['leveledUp'] == true) {
      _showLevelUpNotification(progression);
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: {
          'score': _score,
          'total': _questions.length,
          'answers': _answerDetails,
          'progression': progression,
        },
      );
    }
  }

  void _showAchievementNotifications(List<dynamic> achievements) {
    for (final achievement in achievements) {
      TopNotification.show(
        context,
        message: 'Achievement Unlocked! ${achievement.title}',
        icon: Icons.emoji_events,
        iconColor: Colors.green,
        points: null, // Optionally add points if achievements grant them
        alignment: Alignment.topRight,
      );
    }
  }

  void _showChallengeNotifications(List<dynamic> challenges) {
    for (final challenge in challenges) {
      TopNotification.show(
        context,
        message: 'Daily Challenge Complete! ${challenge.title}',
        icon: Icons.flag,
        iconColor: Colors.blue,
        points: challenge.rewardAmount,
        alignment: Alignment.topRight,
      );
    }
  }

  void _showLevelUpNotification(Map<String, dynamic> progression) {
    TopNotification.show(
      context,
      message: 'Level Up! Level ${progression['oldLevel']} → Level ${progression['newLevel']}',
      icon: Icons.trending_up,
      iconColor: Colors.orange,
      points: null,
      alignment: Alignment.topRight,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit? Your current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _questions.isEmpty || _currentIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Loading Game...'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, accentColor],
            ),
          ),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return TutorialOverlay(
      tutorialKey: 'game',
      steps: TutorialHelper.getGameTutorialSteps(),
      child: Scaffold(
        appBar: _buildGameAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, accentColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildContent(_questions[_currentIndex]),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildGameAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => _showExitGameDialog(),
        icon: const Icon(Icons.home, color: Colors.white, size: 28),
        tooltip: 'Exit to Home',
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.category ?? 'Mixed',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Score
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                '$_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          // Question Progress
          Text(
            'Q: ${_currentIndex + 1}/${_questions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timer with visual indicator
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _timer / _maxTime,
                minHeight: 8,
                backgroundColor: accentColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            AccessibilityManager().getTimerVisualIndicator(
              currentTime: _timer,
              maxTime: _maxTime,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          question.type == 'sound' ? 'Listen to the sound:' : 'Listen to the music:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Audio visual indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              question.type == 'sound' ? Icons.volume_up : Icons.music_note,
              size: 64,
              color: _audioError ? Colors.red : primaryColor,
            ),
            const SizedBox(width: 16),
            AccessibilityManager().getAudioVisualIndicator(
              isPlaying: _isPlaying,
              isMuted: _isMuted,
              volume: _volume,
              size: 32,
            ),
          ],
        ),
        
        if (_audioError) ...[
          const SizedBox(height: 8),
          const Text(
            'Audio file not found - using placeholder',
            style: TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        ...((question.options ?? []).map((option) {
          final isSelected = _selectedAnswer == option;
          final isCorrect = option == question.correctAnswer;
          final showResult = _answered && (isSelected || isCorrect);
          Color backgroundColor = Colors.white;
          Color textColor = Colors.black;
          if (showResult) {
            if (isCorrect) {
              backgroundColor = Colors.green;
              textColor = Colors.white;
            } else if (isSelected) {
              backgroundColor = Colors.red;
              textColor = Colors.white;
            }
          } else if (isSelected) {
            backgroundColor = primaryColor;
            textColor = Colors.white;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _answered ? null : () => _onAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (showResult)
                    AccessibilityManager().getAnswerVisualIndicator(
                      state: isCorrect ? AnswerState.correct : AnswerState.incorrect,
                    ),
                  if (showResult) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 24),
        Text(
          'Score: $_score / ${_questions.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper for difficulty multiplier
  int _getDifficultyMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      case 'expert':
        return 4;
      case 'master':
        return 5;
      default:
        return 1;
    }
  }
} 