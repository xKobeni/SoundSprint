import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/managers/game_manager.dart';
import '../../utils/game_logic/game_logic_factory.dart';
import '../../utils/game_logic/base_game_logic.dart';
import '../widgets/tutorial_overlay.dart';
import 'result_page.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_option_button.dart';
import '../utils/managers/audio_manager.dart';
import '../utils/managers/notification_manager.dart';

class GamePage extends StatefulWidget {
  final String? difficulty;
  final int? timeLimit;
  final String? category;
  final String? gameMode;

  const GamePage({
    Key? key, 
    this.difficulty, 
    this.timeLimit, 
    this.category,
    this.gameMode,
  }) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameManager _gameManager = GameManager();
  bool _showTutorial = false;

  // Add timer controller for circular countdown
  late int _timerMax;
  late int _timerRemaining;

  @override
  void initState() {
    super.initState();
    _timerMax = widget.timeLimit ?? 20;
    _timerRemaining = _timerMax;
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await _gameManager.initialize();
      
      // Load questions with the specified game mode
      await _gameManager.loadQuestions(
        difficulty: widget.difficulty,
        category: widget.category,
        gameMode: widget.gameMode,
      );

      // Check if tutorial should be shown
      _checkTutorial();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('Error initializing game: $e'),
          ),
        );
      }
    }
  }

  void _checkTutorial() {
    // Show tutorial for first-time users
    // This can be enhanced with proper tutorial logic
    setState(() {
      _showTutorial = false; // Set to true if tutorial should be shown
    });
  }

  void _onAnswer(String? answer) async {
    await _gameManager.handleAnswer(answer, context);
    
    // Check if game is finished after a short delay to show answer feedback
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final result = _gameManager.getGameResult();
      if (result != null) {
        // Add a longer delay before navigating to the result page to allow notifications to show
        await Future.delayed(const Duration(seconds: 3));
        _goToResultPage(result);
      }
    }
  }

  void _goToResultPage(GameResult result) {
    AudioManager().stopAll(); // Stop any playing audio before navigating
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: result.score,
          total: result.totalQuestions,
          answers: result.answerDetails,
          progression: {
            'gameMode': result.gameMode,
            'playTime': result.playTime.inSeconds,
            'accuracy': result.accuracy,
          },
          modeSpecificPoints: result.modeSpecificPoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: Stack(
          children: [
            ListenableBuilder(
              listenable: _gameManager,
              builder: (context, child) {
                return SafeArea(
                  child: Column(
                    children: [
                      _buildCustomHeader(context),
                      _buildGameTopBar(),
                      Expanded(child: _buildGameContent()),
                    ],
                  ),
                );
              },
            ),
            // Notification debug button removed
            // Add test notification button for debugging
            Positioned(
              top: 100,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'notif',
                mini: true,
                onPressed: () {
                  NotificationManager.showToast(
                    context,
                    message: 'Test Notification!',
                    icon: Icons.check_circle,
                    backgroundColor: Colors.green[600]!,
                    iconColor: Colors.white,
                  );
                },
                child: const Icon(Icons.notifications),
              ),
            ),
            // Add test level-up and achievement button
            Positioned(
              top: 160,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'test',
                mini: true,
                onPressed: () async {
                  debugPrint('🧪 Testing level-up and achievement notifications...');
                  
                  // Test level-up notification
                  NotificationManager.showGlobalToast(
                    message: 'Test Level Up! You reached Level 5',
                    icon: Icons.emoji_events,
                    backgroundColor: Colors.deepPurple[400]!,
                    iconColor: Colors.amber,
                  );
                  
                  // Wait a bit
                  await Future.delayed(const Duration(seconds: 2));
                  
                  // Test achievement notification
                  NotificationManager.showGlobalToast(
                    message: 'Test Achievement Unlocked: Perfect Score',
                    icon: Icons.star,
                    backgroundColor: Colors.green[600]!,
                    iconColor: Colors.orange,
                  );
                },
                child: const Icon(Icons.science),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final category = _gameManager.questions.isNotEmpty
        ? _gameManager.questions[_gameManager.currentIndex.clamp(0, _gameManager.questions.length - 1)].category
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF7C5CFC)),
              onPressed: () async {
                final shouldExit = await _showExitQuizDialog(context);
                if (shouldExit == true) {
                  await AudioManager().stopAll(); // Stop any playing audio when exiting
                  Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz, color: Color(0xFF7C5CFC), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quiz',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          category.isNotEmpty ? category : 'Game',
                          style: const TextStyle(
                            color: Color(0xFF7C5CFC),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitQuizDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Are you sure you want to exit the quiz? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow() {
    final correct = _gameManager.correctCount;
    final incorrect = _gameManager.incorrectCount;
    final total = _gameManager.questions.length;
    final current = _gameManager.currentIndex + 1;
    final time = _gameManager.timeRemaining;
    final maxTime = _timerMax;
    
    // Calculate current points based on score using the same logic as game_manager.dart
    final currentScore = correct;
    final basePoints = currentScore * 1; // 1 point per correct answer
    final gameMode = _gameManager.currentGameMode ?? 'unknown';
    int modeBonus = 0;
    
    // Calculate mode-specific bonus (matching _calculateModeSpecificPoints logic)
    switch (gameMode) {
      case 'GuessTheSound':
        if (currentScore >= 2) modeBonus = 1;
        break;
      case 'GuessTheMusic':
        modeBonus = currentScore ~/ 3; // +1 for every 3 correct
        break;
      case 'TrueOrFalse':
      case 'Vocabulary':
      case 'GuessTheImage':
        modeBonus = 0;
        break;
      default:
        modeBonus = 0;
    }
    
    // Add perfect score bonus
    if (currentScore == total && currentScore > 0) {
      modeBonus += 2;
    }
    
    final totalPoints = basePoints + modeBonus;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Points Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stars,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Points: $totalPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C5CFC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Correct count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$correct',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
          // Incorrect count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
                  mainAxisSize: MainAxisSize.min,
              children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$incorrect',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
              // Progress indicator
          Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C5CFC).withOpacity(0.3)),
                ),
                child: Text(
                  '$current/$total',
                  style: const TextStyle(
                    color: Color(0xFF7C5CFC),
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          // Timer
          LinearProgressIndicator(
            value: maxTime > 0 ? (maxTime - time) / maxTime : 0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
          ),
          const SizedBox(height: 4),
          Text(
            'Time: ${time}s',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBreakdown() {
    final correct = _gameManager.correctCount;
    final total = _gameManager.questions.length;
    final gameMode = _gameManager.currentGameMode ?? 'unknown';
    final basePoints = correct * 1; // 1 point per correct answer
    int modeBonus = 0;
    String modeName = _gameManager.currentGameModeName;
    
    // Calculate mode-specific bonus (matching _calculateModeSpecificPoints logic)
    switch (gameMode) {
      case 'GuessTheSound':
        if (correct >= 2) modeBonus = 1;
        break;
      case 'GuessTheMusic':
        modeBonus = correct ~/ 3; // +1 for every 3 correct
        break;
      case 'TrueOrFalse':
      case 'Vocabulary':
      case 'GuessTheImage':
        modeBonus = 0;
        break;
      default:
        modeBonus = 0;
    }
    
    // Add perfect score bonus
    if (correct == total && correct > 0) {
      modeBonus += 2;
    }
    
    final totalPoints = basePoints + modeBonus;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Points Breakdown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C5CFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Base Points',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      basePoints.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C5CFC),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Bonus',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      modeBonus.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      totalPoints.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C5CFC),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mode: $modeName',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTopBar() {
    final correct = _gameManager.correctCount;
    final incorrect = _gameManager.incorrectCount;
    final total = _gameManager.questions.length;
    final current = _gameManager.currentIndex + 1;
    final time = _gameManager.timeRemaining;
    final maxTime = _timerMax;
    final gameMode = _gameManager.currentGameMode ?? '';
    
    // Calculate points (same as in _buildProgressRow and _calculateModeSpecificPoints)
    final currentScore = correct;
    final basePoints = currentScore * 1; // 1 point per correct answer
    int modeBonus = 0;
    
    // Calculate mode-specific bonus (matching _calculateModeSpecificPoints logic)
    switch (gameMode) {
      case 'GuessTheSound':
        if (currentScore >= 2) modeBonus = 1;
        break;
      case 'GuessTheMusic':
        modeBonus = currentScore ~/ 3; // +1 for every 3 correct
        break;
      case 'TrueOrFalse':
      case 'Vocabulary':
      case 'GuessTheImage':
        modeBonus = 0;
        break;
      default:
        modeBonus = 0;
    }
    
    // Add perfect score bonus
    if (currentScore == total && currentScore > 0) {
      modeBonus += 2;
    }
    
    final totalPoints = basePoints + modeBonus;

    // Only use this top bar for Vocabulary, True/False, GuessTheSound, GuessTheMusic, GuessTheImage
    if (gameMode != 'Vocabulary' && gameMode != 'TrueOrFalse' && gameMode != 'GuessTheSound' && gameMode != 'GuessTheMusic' && gameMode != 'GuessTheImage') {
      return _buildProgressRow();
    }

    double progress = maxTime > 0 ? (maxTime - time) / maxTime : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Correct/Wrong counts
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 4),
              Text('$correct', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(width: 12),
              Icon(Icons.cancel, color: Colors.red, size: 20),
              SizedBox(width: 4),
              Text('$incorrect', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          Spacer(),
          // Circular timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                  strokeWidth: 6,
                ),
              ),
              Text('$time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5CFC))),
            ],
          ),
          Spacer(),
          // Question number and points
          Row(
            children: [
              Text('$current/$total', style: TextStyle(color: Color(0xFF7C5CFC), fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 10),
              Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 2),
              Text('$totalPoints', style: TextStyle(color: Color(0xFF7C5CFC), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (_gameManager.loading) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading questions...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7C5CFC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_gameManager.errorMessage != null) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${_gameManager.errorMessage}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Check if game is completed and show result
    if (_gameManager.currentIndex >= _gameManager.questions.length) {
      return _buildGameCompletedState();
    }
    final gameMode = _gameManager.currentGameMode ?? '';
    if (gameMode == 'Vocabulary' || gameMode == 'TrueOrFalse' || gameMode == 'GuessTheSound' || gameMode == 'GuessTheMusic' || gameMode == 'GuessTheImage') {
      // No scroll, fill screen, compact spacing
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: _gameManager.buildQuestionWidget(),
            ),
          ],
        ),
      );
    }
    // Default for other modes
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gameManager.buildQuestionWidget(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCompletedState() {
    // Get the final result
    final result = _gameManager.getGameResult();
    
    if (result != null) {
      // Navigate to result page after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _goToResultPage(result);
          }
        });
      });
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Game Completed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Final Score: ${_gameManager.score}/${_gameManager.questions.length}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preparing results...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameManager.dispose();
    super.dispose();
  }
} 