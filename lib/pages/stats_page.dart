import 'package:flutter/material.dart';
import '../utils/managers/stats_manager.dart';
import '../utils/managers/daily_points_manager.dart';
import '../utils/managers/difficulty_progression_manager.dart';
import '../utils/managers/user_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _categoryStats = {};
  Map<String, dynamic> _difficultyStats = {};
  Map<String, dynamic> _progressionData = {};
  Map<String, dynamic> _gameModeStats = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        StatsManager.getAllStats(),
        StatsManager.getCategoryStats(),
        StatsManager.getDifficultyStats(),
        _loadProgressionData(),
        _loadGameModeStats(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, dynamic>;
          _categoryStats = results[1] as Map<String, dynamic>;
          _difficultyStats = results[2] as Map<String, dynamic>;
          _progressionData = results[3] as Map<String, dynamic>;
          _gameModeStats = results[4] as Map<String, dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _showErrorDialog('Failed to load stats: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _loadProgressionData() async {
    final level = await DifficultyProgressionManager.getUserLevel();
    final experience = await DifficultyProgressionManager.getUserExperience();
    final unlockedDifficulties = await DifficultyProgressionManager.getUnlockedDifficulties();
    return {
      'level': level,
      'experience': experience,
      'unlockedDifficulties': unlockedDifficulties,
      'nextLevelExp': _getNextLevelExperience(level),
    };
  }

  Future<Map<String, dynamic>> _loadGameModeStats() async {
    return await StatsManager.getGameModeStats();
  }

  int _getNextLevelExperience(int currentLevel) {
    final requirements = [0, 100, 300, 600, 1000];
    if (currentLevel < requirements.length) {
      return requirements[currentLevel];
    }
    return 100 * (currentLevel + 1) * (currentLevel + 1);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7C5CFC)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 20,
        title: _buildHeader(),
        backgroundColor: const Color(0xFFE9E0FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C5CFC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF7C5CFC),
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Overview'),
            Tab(icon: Icon(Icons.games), text: 'Game Modes'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: TabBarView(
            controller: _tabController,
              children: [
              _buildOverviewTab(),
              _buildGameModesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stats',
                style: TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildProgressionCard(),
          const SizedBox(height: 24),
          _buildOverallPerformanceSection(),
          const SizedBox(height: 24),
          _buildDailyPointsSection(),
          const SizedBox(height: 24),
          _buildDetailedStatsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProgressionCard() {
    final level = _progressionData['level'] ?? 1;
    final experience = _progressionData['experience'] ?? 0;
    final nextLevelExp = _progressionData['nextLevelExp'] ?? 100;
    final progress = (experience / nextLevelExp).clamp(0.0, 1.0);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 8),
              Text(
                'Level $level',
                style: const TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$experience / $nextLevelExp XP',
                style: const TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEE6FF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% to next level',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2.0),
          child: Text(
            'Overall Performance',
            style: TextStyle(
              color: Color(0xFF7C5CFC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
              children: [
                _buildStatCard(
                  icon: Icons.games_rounded,
                  label: 'Games Played',
                  value: '${_stats['gamesPlayed'] ?? 0}',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'High Score',
                  value: '${_stats['highScore'] ?? 0}',
                  color: Colors.amber,
                ),
                _buildStatCard(
                  icon: Icons.show_chart_rounded,
                  label: 'Avg. Score',
                  value: (_stats['averageScore'] ?? 0.0).toStringAsFixed(1),
                  color: Colors.lightBlue,
                ),
                _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Accuracy',
                  value: '${((_stats['accuracy'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                  color: Colors.green,
                ),
                _buildStatCard(
                  icon: Icons.access_time_rounded,
                  label: 'Total Playtime',
                  value: _formatPlaytime(_stats['totalPlaytime'] ?? 0),
                  color: Colors.purple,
                ),
                _buildStatCard(
                  icon: Icons.whatshot_rounded,
                  label: 'Best Streak',
                  value: '${_stats['highestStreak'] ?? 0}',
                  color: Colors.red,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailedStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Stats',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
              children: [
                _buildStatCard(
                  icon: Icons.flash_on_rounded,
                  label: 'Current Streak',
                  value: '${_stats['currentStreak'] ?? 0}',
                  color: Colors.deepOrange,
                ),
                _buildStatCard(
                  icon: Icons.question_answer_rounded,
                  label: 'Total Questions',
                  value: '${_stats['totalQuestions'] ?? 0}',
                  color: Colors.teal,
                ),
                _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Best Category',
                  value: _getBestCategory(),
                  color: Colors.indigo,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameModesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildGameModeStats(),
          const SizedBox(height: 24),
          _buildDifficultyStats(),
          const SizedBox(height: 24),
          _buildCategoryProgressSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGameModeStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Mode Performance',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_gameModeStats.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No game mode data available yet. Play some games to see your performance!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              final childAspectRatio = constraints.maxWidth > 600 ? 2.0 : 1.5;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: _gameModeStats.entries.map((entry) {
                  final mode = entry.key;
                  final stats = entry.value as Map<String, dynamic>;
                  return _buildGameModeCard(mode, stats);
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildGameModeCard(String mode, Map<String, dynamic> stats) {
    final gamesPlayed = stats['gamesPlayed'] ?? 0;
    final bestScore = stats['bestScore'] ?? 0;
    final avgAccuracy = stats['avgAccuracy'] ?? 0.0;
    final totalScore = stats['totalScore'] ?? 0;
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGameModeDisplayName(mode),
              style: const TextStyle(
              color: Color(0xFF7C5CFC),
              fontSize: 16,
                fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Games', '$gamesPlayed'),
              ),
              Expanded(
                child: _buildMiniStat('Best Score', '$bestScore'),
              ),
              Expanded(
                child: _buildMiniStat('Accuracy', '${(avgAccuracy * 100).toStringAsFixed(1)}%'),
              ),
            ],
          ),
          if (gamesPlayed > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat('Total Score', '$totalScore'),
                ),
                Expanded(
                  child: _buildMiniStat('Avg Score', '${(totalScore / gamesPlayed).toStringAsFixed(1)}'),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getGameModeDisplayName(String mode) {
    switch (mode) {
      case 'GuessTheSound':
        return 'Guess the Sound';
      case 'GuessTheMusic':
        return 'Guess the Music';
      case 'GuessTheImage':
        return 'Guess the Image';
      case 'TrueOrFalse':
        return 'True or False';
      case 'Vocabulary':
        return 'Vocabulary';
      default:
        return mode;
    }
  }

  Widget _buildDifficultyStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty Performance',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_difficultyStats.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No difficulty data available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          ..._difficultyStats.entries.map((entry) {
            final difficulty = entry.key;
            final stats = entry.value as Map<String, dynamic>;
            final gamesPlayed = stats['gamesPlayed'] ?? 0;
            final totalScore = stats['totalScore'] ?? 0;
            final totalQuestions = stats['totalQuestions'] ?? 0;
            final accuracy = totalQuestions > 0 ? (totalScore / totalQuestions) : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat('Games', '$gamesPlayed'),
                      ),
                      Expanded(
                        child: _buildMiniStat('Accuracy', '${(accuracy * 100).toStringAsFixed(1)}%'),
                      ),
                      Expanded(
                        child: _buildMiniStat('Best Score', '${stats['highScore'] ?? 0}'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCategoryProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Performance',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_categoryStats.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No category data available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          ..._categoryStats.entries.map((entry) {
            final category = entry.key;
            final stats = entry.value as Map<String, dynamic>;
            final gamesPlayed = stats['gamesPlayed'] ?? 0;
            final totalScore = stats['totalScore'] ?? 0;
            final totalQuestions = stats['totalQuestions'] ?? 0;
            final accuracy = totalQuestions > 0 ? (totalScore / totalQuestions) : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat('Games', '$gamesPlayed'),
                      ),
                      Expanded(
                        child: _buildMiniStat('Accuracy', '${(accuracy * 100).toStringAsFixed(1)}%'),
                      ),
                      Expanded(
                        child: _buildMiniStat('Best Score', '${stats['highScore'] ?? 0}'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Points',
          style: TextStyle(
            color: Color(0xFF7C5CFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: DailyPointsManager.getDailyStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load daily points',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            final stats = snapshot.data ?? {};
            final todayPoints = stats['todayPoints'] ?? 0;
            final dailyGoal = stats['dailyGoal'] ?? 500;
            final progress = stats['progress'] ?? 0.0;
            final averagePoints = stats['averagePoints'] ?? 0.0;
            final bestPoints = stats['bestPoints'] ?? 0;
            return Column(
              children: [
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Color(0xFFFFD700), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Today\'s Progress',
                            style: TextStyle(
                              color: Color(0xFF7C5CFC),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$todayPoints / $dailyGoal',
                            style: const TextStyle(
                              color: Color(0xFF7C5CFC),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEEE6FF),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% of daily goal',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _buildStatCard(
                          icon: Icons.stars,
                          label: 'Today\'s Points',
                          value: '$todayPoints',
                          color: const Color(0xFFFFD700),
                        ),
                        _buildStatCard(
                          icon: Icons.trending_up,
                          label: 'Daily Goal',
                          value: '$dailyGoal',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.analytics,
                          label: 'Avg. Daily',
                          value: averagePoints.toStringAsFixed(0),
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.emoji_events,
                          label: 'Best Day',
                          value: '$bestPoints',
                          color: Colors.orange,
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C5CFC),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String _getBestCategory() {
    if (_categoryStats.isNotEmpty) {
      String bestCategory = '';
      double bestAccuracy = 0.0;
      _categoryStats.forEach((category, stats) {
        final totalScore = stats['totalScore'] ?? 0;
        final totalQuestions = stats['totalQuestions'] ?? 0;
        final accuracy = totalQuestions > 0 ? totalScore / totalQuestions : 0.0;
        if (accuracy > bestAccuracy) {
          bestAccuracy = accuracy;
          bestCategory = category;
        }
      });
      if (bestCategory.isNotEmpty) {
        if (bestCategory.length > 12) {
          return '${bestCategory.substring(0, 12)}...';
        }
        return bestCategory;
      }
    }
    return 'N/A';
  }

  String _formatPlaytime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    } else if (m > 0) {
      return '${m}m ${s}s';
    } else {
      return '${s}s';
    }
  }
} 