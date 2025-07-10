import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/managers/user_preferences.dart';
import '../utils/managers/stats_manager.dart';
import '../utils/managers/daily_points_manager.dart';
import 'game_selection_page.dart';
import 'category_selection_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  String _displayName = '';
  String? _avatarPath;
  late UserPreferences _userPreferences;

  @override
  void initState() {
    super.initState();
    _userPreferences = UserPreferences();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to UserPreferences changes
    _userPreferences.addListener(_onUserPreferencesChanged);
  }

  @override
  void dispose() {
    _userPreferences.removeListener(_onUserPreferencesChanged);
    super.dispose();
  }

  void _onUserPreferencesChanged() {
    if (mounted) {
      try {
        setState(() {
          _avatarPath = _userPreferences.avatarPath;
          _displayName = _userPreferences.displayName;
        });
      } catch (e) {
        // Handle any errors that might occur during state update
        debugPrint('Error updating home page from UserPreferences: $e');
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final stats = await StatsManager.getAllStats();
      final dailyStats = await DailyPointsManager.getDailyStats();
      final user = await _userPreferences.getUser();

      if (mounted) {
        setState(() {
          _stats = {...stats, ...dailyStats};
          _avatarPath = _userPreferences.avatarPath;
          _displayName = user?.name ?? _userPreferences.displayName;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFFE9E0FF), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 24),
            _buildDailyProgressCard(),
            const SizedBox(height: 24),
            _buildQuizVaultSection(),
            const SizedBox(height: 32),
            _buildMoreGamesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFE9E0FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFFFB6B6),
                    backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                    child: _avatarPath == null ? const Icon(Icons.person, size: 28, color: Colors.white) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _userPreferences,
                      builder: (context, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF7C5CFC),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Lv. ${_userPreferences.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _displayName,
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Icon(Icons.stars, color: Color(0xFFFFD700), size: 28),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _userPreferences,
                builder: (context, _) {
                  return Text(
                    _userPreferences.points.toString(),
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyProgressCard() {
    return FutureBuilder<int>(
      future: DailyPointsManager.getTodayPoints(),
      builder: (context, snapshot) {
        final todayPoints = snapshot.data ?? 0;
        
        return Container(
          width: double.infinity,
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
                  const Icon(Icons.anchor, color: Color(0xFF7C5CFC), size: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'Daily Progress',
                    style: TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$todayPoints',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Daily Points Progress
              Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Points',
                    style: TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<int>(
                    future: DailyPointsManager.getDailyGoal(),
                    builder: (context, goalSnapshot) {
                      final dailyGoal = goalSnapshot.data ?? 500;
                      return Text(
                        '$todayPoints / $dailyGoal',
                        style: const TextStyle(
                          color: Color(0xFF7C5CFC),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<double>(
                future: DailyPointsManager.getDailyGoalProgress(),
                builder: (context, progressSnapshot) {
                  final progress = progressSnapshot.data ?? 0.0;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFEEE6FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Games Played Progress
              Row(
                children: [
                  const Icon(Icons.games, color: Color(0xFF7C5CFC), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Games Played',
                    style: TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_stats['todayGames'] ?? 0} / ${_stats['dailyGamesGoal'] ?? 10}',
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _stats['gamesProgress'] ?? 0.0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEEE6FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizVaultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quiz Vault',
              style: TextStyle(
                color: Color(0xFF7C5CFC),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameSelectionPage()),
                );
              },
              child: const Text('View All', style: TextStyle(color: Color(0xFF7C5CFC))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.volume_up,
          title: 'Animal Sound',
          subcategories: 'Sound Quiz',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelectionPage(
                  gameMode: 'GuessTheSound',
                  gameModeName: 'Sound Quiz',
                  initialCategory: 'Animal Sound',
                  initialDifficulty: 'Easy',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.music_note,
          title: 'Anime Openings',
          subcategories: 'Music Quiz',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelectionPage(
                  gameMode: 'GuessTheMusic',
                  gameModeName: 'Music Quiz',
                  initialCategory: 'Anime Openings',
                  initialDifficulty: 'Easy',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.music_note,
          title: 'Kpop Music',
          subcategories: 'Music Quiz',
          color: Colors.pink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelectionPage(
                  gameMode: 'GuessTheMusic',
                  gameModeName: 'Music Quiz',
                  initialCategory: 'Kpop Music',
                  initialDifficulty: 'Easy',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuizVaultCard({required IconData icon, required String title, required String subcategories, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subcategories,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreGamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Games',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildGameCard(
              icon: Icons.translate,
              label: 'Vocabulary',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionPage(
                      gameMode: 'Vocabulary',
                      gameModeName: 'Vocabulary',
                    ),
                  ),
                );
              },
            ),
            _buildGameCard(
              icon: Icons.check_circle,
              label: 'True or False',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionPage(
                      gameMode: 'TrueOrFalse',
                      gameModeName: 'True or False',
                    ),
                  ),
                );
              },
            ),
            _buildGameCard(
              icon: Icons.music_note,
              label: 'Music Quiz',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionPage(
                      gameMode: 'GuessTheMusic',
                      gameModeName: 'Music Quiz',
                    ),
                  ),
                );
              },
            ),
            _buildGameCard(
              icon: Icons.volume_up,
              label: 'Sound Quiz',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionPage(
                      gameMode: 'GuessTheSound',
                      gameModeName: 'Sound Quiz',
                    ),
                  ),
                );
              },
            ),
            _buildGameCard(
              icon: Icons.image,
              label: 'Guess the Image',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionPage(
                      gameMode: 'GuessTheImage',
                      gameModeName: 'Guess the Image',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF7C5CFC), size: 36),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  final String gameMode;
  final String category;
  final String difficulty;

  const GamePage({
    Key? key,
    required this.gameMode,
    required this.category,
    required this.difficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF7C5CFC),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Game Page Coming Soon!',
          style: TextStyle(fontSize: 24, color: Color(0xFF7C5CFC)),
        ),
      ),
    );
  }
}

class GuessTheImagePage extends StatelessWidget {
  const GuessTheImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Image'),
        backgroundColor: const Color(0xFF7C5CFC),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Guess the Image Coming Soon!',
          style: TextStyle(fontSize: 24, color: Color(0xFF7C5CFC)),
        ),
      ),
    );
  }
} 