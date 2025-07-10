import 'package:flutter/material.dart';
import '../utils/managers/game_manager.dart';
import '../../utils/game_logic/game_logic_factory.dart';
import '../widgets/tutorial_overlay.dart';
import '../utils/managers/tutorial_manager.dart';
import 'category_selection_page.dart';

class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({Key? key}) : super(key: key);

  @override
  State<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final GameManager _gameManager = GameManager();
  List<GameModeInfo> _gameModes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGameModes();
  }

  Future<void> _loadGameModes() async {
    try {
      await _gameManager.initialize();
      setState(() {
        _gameModes = _gameManager.getAvailableGameModes();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game modes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      tutorialKey: 'game_selection',
      steps: TutorialHelper.getGameTutorialSteps(),
      onComplete: () {
        // Tutorial completed, no action needed
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Game Mode',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE9E0FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF7C5CFC)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                ),
              )
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  children: [
                    const SizedBox(height: 24),
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    _buildGameModesList(),
                    const SizedBox(height: 32),
                  ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.games, color: Color(0xFF7C5CFC), size: 36),
              const SizedBox(width: 12),
              const Text(
                'Game Modes',
                style: TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select Your Game Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose from different types of challenges',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModesList() {
    return Column(
      children: _gameModes.map((gameMode) => _buildGameModeCard(gameMode)).toList(),
    );
  }

  Widget _buildGameModeCard(GameModeInfo gameMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _startGame(gameMode),
        child: Container(
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C5CFC), Color(0xFF9B6DFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  gameMode.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameMode.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C5CFC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gameMode.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: gameMode.supportedTypes.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C5CFC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getTypeDisplayName(type),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C5CFC),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7C5CFC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'sound':
        return 'Sound';
      case 'music':
        return 'Music';
      case 'truefalse':
        return 'True/False';
      case 'vocabulary':
        return 'Vocabulary';
      case 'image':
        return 'Image';
      default:
        return type;
    }
  }

  void _startGame(GameModeInfo gameMode) async {
    // Show game mode specific tutorial if not shown before
    bool tutorialShown = await TutorialManager.isGameModeTutorialShown(gameMode.id);
    
    if (!tutorialShown) {
      // Show tutorial overlay for this specific game mode
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TutorialOverlay(
            tutorialKey: gameMode.id,
            steps: _getTutorialStepsForGameMode(gameMode.id),
            onComplete: () {
              Navigator.of(context).pop();
              _navigateToCategorySelection(gameMode);
            },
            child: Container(), // Empty container since we're using dialog
          ),
        );
      }
    } else {
      // Tutorial already shown, navigate directly
      _navigateToCategorySelection(gameMode);
    }
  }

  void _navigateToCategorySelection(GameModeInfo gameMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionPage(
          gameMode: gameMode.id,
          gameModeName: gameMode.name,
        ),
      ),
    );
  }

  List<TutorialStep> _getTutorialStepsForGameMode(String gameModeId) {
    switch (gameModeId) {
      case 'GuessTheSound':
        return TutorialHelper.getGuessTheSoundTutorialSteps();
      case 'GuessTheMusic':
        return TutorialHelper.getGuessTheMusicTutorialSteps();
      case 'TrueOrFalse':
        return TutorialHelper.getTrueOrFalseTutorialSteps();
      case 'Vocabulary':
        return TutorialHelper.getVocabularyTutorialSteps();
      case 'GuessTheImage':
        return TutorialHelper.getGuessTheImageTutorialSteps();
      default:
        return TutorialHelper.getGameTutorialSteps();
    }
  }

  @override
  void dispose() {
    _gameManager.dispose();
    super.dispose();
  }
} 