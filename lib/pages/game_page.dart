import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/game_manager.dart';
import '../utils/game_logic/game_logic_factory.dart';
import '../utils/game_logic/base_game_logic.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/top_notification.dart';
import 'result_page.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_option_button.dart';

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
          SnackBar(content: Text('Error initializing game: $e')),
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
        _goToResultPage(result);
      }
    }
  }

  void _goToResultPage(GameResult result) {
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: ListenableBuilder(
        listenable: _gameManager,
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(context),
                _buildProgressRow(),
                Expanded(child: _buildGameContent()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final category = _gameManager.questions.isNotEmpty
        ? _gameManager.questions[_gameManager.currentIndex.clamp(0, _gameManager.questions.length - 1)].category
        : '';
    return Container(
      color: const Color(0xFFF5F3FF),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7C5CFC)),
            onPressed: () async {
              final shouldExit = await _showExitQuizDialog(context);
              if (shouldExit == true) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),
          const Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF7C5CFC),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          if (category.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              category,
              style: const TextStyle(
                color: Color(0xFF7C5CFC),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Correct count
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 2),
              Text('$correct', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 12),
          // Incorrect count
          Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 20),
              const SizedBox(width: 2),
              Text('$incorrect', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          // Circular timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: time / maxTime,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                  backgroundColor: const Color(0xFFE0D7FF),
                ),
              ),
              Text('$time', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C5CFC))),
            ],
          ),
          const Spacer(),
          // Question number
          Text('$current/$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C5CFC))),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (_gameManager.loading) {
      return const Center(
        child: Column(
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
              ),
            ),
          ],
        ),
      );
    }

    if (_gameManager.errorMessage != null) {
      return Center(
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
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeGame(),
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

    // Use the new shared widgets for question and answers, with scroll and padding
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _gameManager.buildQuestionWidget(),
          const SizedBox(height: 32),
        ],
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Color(0xFF7C5CFC),
          ),
          const SizedBox(height: 16),
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
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preparing results...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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