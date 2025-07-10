import 'package:flutter/material.dart';
import '../../utils/question_loader.dart';
import '../../utils/game_logic/game_logic_factory.dart';
import 'game_page.dart';

class CategorySelectionPage extends StatefulWidget {
  final String gameMode;
  final String gameModeName;
  final String? initialCategory;
  final String? initialDifficulty;

  const CategorySelectionPage({
    Key? key,
    required this.gameMode,
    required this.gameModeName,
    this.initialCategory,
    this.initialDifficulty,
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
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _maybeJumpToInitialTab() {
    if (widget.initialDifficulty != null && 
        _difficulties.isNotEmpty && 
        _tabController != null && 
        mounted) {
      final idx = _difficulties.indexOf(widget.initialDifficulty!);
      if (idx != -1 && _tabController!.index != idx) {
        try {
          _tabController!.animateTo(idx);
          setState(() {
            _selectedDifficulty = _difficulties[idx];
          });
        } catch (e) {
          // Handle any animation errors
          debugPrint('Error animating to tab: $e');
        }
      }
    }
  }

  void _initializeTabController() {
    if (!mounted) return;
    
    if (_tabController != null) {
      _tabController!.dispose();
    }
    
    if (_difficulties.isNotEmpty) {
      try {
        _tabController = TabController(length: _difficulties.length, vsync: this);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _maybeJumpToInitialTab();
          }
        });
      } catch (e) {
        debugPrint('Error initializing TabController: $e');
      }
    }
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
      
      // Load categories for each valid difficulty
      for (final difficulty in validDifficulties) {
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
      
      if (mounted) {
        setState(() {
          _difficulties = validDifficulties;
          _selectedDifficulty = validDifficulties.isNotEmpty ? validDifficulties.first : 'Easy';
          _loading = false;
        });
        
        // Initialize tab controller after setState
        _initializeTabController();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
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
        title: Text(
          widget.gameModeName,
          style: const TextStyle(
            color: Color(0xFF7C5CFC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE9E0FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF7C5CFC)),
        bottom: _difficulties.isNotEmpty && _tabController != null ? TabBar(
          controller: _tabController!,
          indicatorColor: const Color(0xFF7C5CFC),
          labelColor: const Color(0xFF7C5CFC),
          unselectedLabelColor: Colors.black54,
          indicatorSize: TabBarIndicatorSize.tab,
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
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                ),
              )
            : _difficulties.isEmpty
                ? _buildNoContentState()
                : _tabController == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                        ),
                      )
                    : SafeArea(
                        child: TabBarView(
                          controller: _tabController!,
                          children: _difficulties.map((difficulty) {
                            return _buildDifficultyView(difficulty);
                          }).toList(),
                        ),
                      ),
      ),
    );
  }

  Widget _buildDifficultyView(String difficulty) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildHeaderSection(difficulty),
          const SizedBox(height: 24),
          _categoriesByDifficulty[difficulty]?.isEmpty ?? true
              ? _buildEmptyState(difficulty)
              : _buildCategoryListView(difficulty),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String difficulty) {
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
              const Icon(Icons.category, color: Color(0xFF7C5CFC), size: 36),
              const SizedBox(width: 12),
              Text(
                '$difficulty Categories',
                style: const TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a category to start playing',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListView(String difficulty) {
    final categories = _categoriesByDifficulty[difficulty] ?? [];
    final initialIndex = (widget.initialCategory != null && difficulty == (widget.initialDifficulty ?? _selectedDifficulty))
        ? categories.indexOf(widget.initialCategory!)
        : -1;
    final controller = ScrollController();
    if (initialIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.hasClients) {
          controller.jumpTo((initialIndex * 140.0).clamp(0, controller.position.maxScrollExtent));
        }
      });
    }
    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, difficulty);
      },
    );
  }

  Widget _buildCategoryCard(String category, String difficulty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _startGame(category, difficulty),
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
                  gradient: LinearGradient(
                    colors: [
                      _getDifficultyColor(difficulty),
                      _getDifficultyColor(difficulty).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                        fontSize: 18,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.quiz,
                          size: 16,
                          color: Color(0xFF7C5CFC),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_questionCounts[difficulty]?[category] ?? 0} questions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7C5CFC),
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
    return Container(
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
              Icons.category_outlined,
              size: 64,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No categories available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'for $difficulty difficulty',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentState() {
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
              Icons.category_outlined,
              size: 64,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No content available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'for ${widget.gameModeName}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
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
    _tabController?.dispose();
    super.dispose();
  }
} 