import 'package:flutter/material.dart';
import '../utils/game_logic/game_logic_factory.dart';
import '../utils/game_manager.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Game Mode'),
        backgroundColor: const Color(0xFF7C5CFC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C5CFC), Color(0xFF9B6DFF)],
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Your Game Mode',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose from different types of challenges',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _gameModes.length,
                          itemBuilder: (context, index) {
                            final gameMode = _gameModes[index];
                            return _buildGameModeCard(gameMode);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGameModeCard(GameModeInfo gameMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _startGame(gameMode),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CFC),
                    borderRadius: BorderRadius.circular(12),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C5CFC),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gameMode.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
      default:
        return type;
    }
  }

  void _startGame(GameModeInfo gameMode) {
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

  @override
  void dispose() {
    _gameManager.dispose();
    super.dispose();
  }
} 