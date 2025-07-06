import 'package:flutter/material.dart';
import '../utils/question_loader.dart';
import '../utils/game_logic/game_logic_factory.dart';
import 'game_page.dart';

class CategorySelectionPage extends StatefulWidget {
  final String gameMode;
  final String gameModeName;

  const CategorySelectionPage({
    Key? key,
    required this.gameMode,
    required this.gameModeName,
  }) : super(key: key);

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage>
    with SingleTickerProviderStateMixin {
  Map<String, List<String>> _categoriesByDifficulty = {};
  Map<String, Map<String, int>> _questionCounts = {};
  List<String> _difficulties = [];
  String _selectedDifficulty = 'Easy';
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize with a default length, will be updated in _loadCategories
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // First, get all available difficulties for this game mode
      final allDifficulties = await QuestionLoader.getAvailableDifficulties(
        mode: widget.gameMode,
      );
      
      // Only include difficulties that actually have categories with questions
      final validDifficulties = <String>[];
      for (final difficulty in allDifficulties) {
        final categories = await QuestionLoader.getAvailableCategories(
          mode: widget.gameMode,
          difficulty: difficulty,
        );
        if (categories.isNotEmpty) {
          validDifficulties.add(difficulty);
        }
      }
      
      setState(() {
        _difficulties = validDifficulties;
        _selectedDifficulty = validDifficulties.isNotEmpty ? validDifficulties.first : 'Easy';
      });
      
      // Initialize tab controller with the correct number of tabs
      if (_tabController.length != _difficulties.length) {
        _tabController.dispose();
        _tabController = TabController(length: _difficulties.length, vsync: this);
      }
      
      // Load categories for each valid difficulty
      for (final difficulty in _difficulties) {
        final categories = await QuestionLoader.getAvailableCategories(
          mode: widget.gameMode,
          difficulty: difficulty,
        );
        _categoriesByDifficulty[difficulty] = categories;
        
        // Load question counts for each category
        _questionCounts[difficulty] = {};
        for (final category in categories) {
          final count = await QuestionLoader.getQuestionCount(
            mode: widget.gameMode,
            category: category,
            difficulty: difficulty,
          );
          _questionCounts[difficulty]![category] = count;
        }
      }
      
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameModeName),
        backgroundColor: const Color(0xFF7C5CFC),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: _difficulties.isNotEmpty ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _difficulties.map((difficulty) {
            return Tab(
              child: Text(
                difficulty,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ) : null,
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
            : _difficulties.isEmpty
                ? _buildNoContentState()
                : SafeArea(
                    child: TabBarView(
                      controller: _tabController,
                      children: _difficulties.map((difficulty) {
                        return _buildDifficultyView(difficulty);
                      }).toList(),
                    ),
                  ),
      ),
    );
  }

  Widget _buildDifficultyView(String difficulty) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$difficulty Categories',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a category to start playing',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _categoriesByDifficulty[difficulty]?.isEmpty ?? true
                ? _buildEmptyState(difficulty)
                : ListView.builder(
                    itemCount: _categoriesByDifficulty[difficulty]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final category = _categoriesByDifficulty[difficulty]![index];
                      return _buildCategoryCard(category, difficulty);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, String difficulty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _startGame(category, difficulty),
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
                    color: _getDifficultyColor(difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
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
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C5CFC),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getDifficultyColor(difficulty),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCategoryDescription(category),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_questionCounts[difficulty]?[category] ?? 0} questions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return const Color(0xFF7C5CFC);
    }
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Sound') || category.contains('Animal')) {
      return Icons.volume_up;
    } else if (category.contains('Music') || category.contains('Kpop') || 
               category.contains('Anime') || category.contains('OPM')) {
      return Icons.music_note;
    } else if (category.contains('Meme')) {
      return Icons.sentiment_satisfied;
    } else if (category.contains('Nature')) {
      return Icons.nature;
    } else if (category.contains('Knowledge') || category.contains('Science')) {
      return Icons.school;
    } else if (category.contains('Vocabulary') || category.contains('English') || 
               category.contains('Filipino')) {
      return Icons.translate;
    } else {
      return Icons.quiz;
    }
  }

  String _getCategoryDescription(String category) {
    if (category.contains('Sound') || category.contains('Animal')) {
      return 'Test your ability to identify different sounds and animal noises';
    } else if (category.contains('Music') || category.contains('Kpop') || 
               category.contains('Anime') || category.contains('OPM')) {
      return 'Challenge yourself with music recognition from various genres';
    } else if (category.contains('Meme')) {
      return 'Have fun identifying popular meme sounds and references';
    } else if (category.contains('Nature')) {
      return 'Explore and identify natural sounds from the environment';
    } else if (category.contains('Knowledge') || category.contains('Science')) {
      return 'Test your general knowledge and scientific facts';
    } else if (category.contains('Vocabulary') || category.contains('English') || 
               category.contains('Filipino')) {
      return 'Expand your vocabulary with word meanings and translations';
    } else {
      return 'Challenge yourself with various types of questions';
    }
  }

  Widget _buildEmptyState(String difficulty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No categories available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'for $difficulty difficulty',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentState() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for ${widget.gameModeName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(String category, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          gameMode: widget.gameMode,
          category: category,
          difficulty: difficulty,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 