import 'package:flutter/material.dart';
import '../utils/managers/stats_manager.dart';
import '../utils/managers/daily_points_manager.dart';
import '../widgets/bottom_nav_bar.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  String _mostMissedQuestion = '';
  Map<String, dynamic> _categoryStats = {};
  Map<String, dynamic> _difficultyStats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await StatsManager.getAllStats();
      final mostMissed = await StatsManager.getMostMissedQuestion();
      final categoryStats = await StatsManager.getCategoryStats();
      final difficultyStats = await StatsManager.getDifficultyStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _mostMissedQuestion = mostMissed;
          _categoryStats = categoryStats;
          _difficultyStats = difficultyStats;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildOverallPerformanceSection(),
                const SizedBox(height: 24),
                _buildDailyPointsSection(),
                const SizedBox(height: 24),
                _buildDetailedStatsSection(),
                const SizedBox(height: 32),
                _buildResetStatsButton(),
                const SizedBox(height: 32),
              ],
            ),
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
                  icon: Icons.whatshot_rounded,
                  label: 'Highest Streak',
                  value: '${_stats['highestStreak'] ?? 0}',
                  color: Colors.red,
                ),
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

  Widget _buildResetStatsButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.refresh),
        label: const Text('Reset All Stats'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C5CFC),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Stats'),
              content: const Text('Are you sure you want to reset all your statistics? This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await StatsManager.resetAllStats();
            await _loadStats();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All stats have been reset.')),
              );
            }
          }
        },
      ),
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
    // Get the category with the highest accuracy
    if (_categoryStats.isNotEmpty) {
      String bestCategory = '';
      double bestAccuracy = 0.0;
      
      _categoryStats.forEach((category, stats) {
        final accuracy = stats['accuracy'] ?? 0.0;
        if (accuracy > bestAccuracy) {
          bestAccuracy = accuracy;
          bestCategory = category;
        }
      });
      
      if (bestCategory.isNotEmpty) {
        // Truncate long category names
        if (bestCategory.length > 12) {
          return '${bestCategory.substring(0, 12)}...';
        }
        return bestCategory;
      }
    }
    return 'N/A';
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
                // Today's Progress Card
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
                
                // Daily Points Stats Grid
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
} 