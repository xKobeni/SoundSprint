import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/game_manager.dart';
import '../utils/game_logic/game_logic_factory.dart';
import '../utils/game_logic/base_game_logic.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/top_notification.dart';
import 'result_page.dart';

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

  @override
  void initState() {
    super.initState();
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
          return Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: _buildGameContent()),
                ],
              ),
              // Tutorial overlay - disabled for now
              // if (_showTutorial)
              //   TutorialOverlay(
              //     child: Container(),
              //     tutorialKey: 'game',
              //     steps: [],
              //     onComplete: () {
              //       setState(() {
              //         _showTutorial = false;
              //       });
              //     },
              //   ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF7C5CFC),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            
            const SizedBox(width: 16),
            
            // Game mode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gameManager.currentGameMode?.toUpperCase() ?? 'GAME',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Question ${_gameManager.currentIndex + 1} of ${_gameManager.questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_gameManager.timeRemaining}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_gameManager.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

    // Build the question widget using the current game logic
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _gameManager.buildQuestionWidget(),
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