import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/managers/achievement_manager.dart';

class AchievementsPage extends StatefulWidget {
  final bool showBottomNav;
  const AchievementsPage({super.key, this.showBottomNav = false});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<Achievement> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }





  Future<void> _loadAchievements() async {
    try {
      final achievements = await AchievementManager.getAllAchievements();
      if (mounted) {
        setState(() {
          _achievements = achievements;
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7C5CFC)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildHeader(),
        backgroundColor: const Color(0xFFE9E0FF),
        elevation: 0,
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        child: SafeArea(
          child: Column(
            children: [
              // Achievement summary
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Unlocked',
                      '${_achievements.where((a) => a.isUnlocked).length}',
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      'Total',
                      '${_achievements.length}',
                      Icons.emoji_events,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Progress',
                      '${_achievements.isNotEmpty ? ((_achievements.where((a) => a.isUnlocked).length / _achievements.length) * 100).round() : 0}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Achievement list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _achievements.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadAchievements,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _achievements.length,
                              itemBuilder: (context, index) {
                                final achievement = _achievements[index];
                                return _buildAchievementCard(achievement);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
                'Achievements',
                style: TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Debug button for testing achievements
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF7C5CFC)),
          onPressed: _loadAchievements,
          tooltip: 'Refresh achievements',
        ),
        IconButton(
          icon: const Icon(Icons.info, color: Color(0xFF7C5CFC)),
          onPressed: _showDebugInfo,
          tooltip: 'Show debug info',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C5CFC),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.maxProgress > 0 ? achievement.progress / achievement.maxProgress : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Achievement icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.amber : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Icon(
                  achievement.icon,
                  size: 32,
                  color: isUnlocked ? Colors.deepOrange : Colors.grey[600],
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Achievement details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEEE6FF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUnlocked ? Colors.green : const Color(0xFF7C5CFC),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}/${achievement.maxProgress}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  
                  if (isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Unlock indicator
            if (isUnlocked)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDebugInfo() async {
    final stats = await AchievementManager.getCurrentStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Score: ${stats['totalScore']}'),
            Text('Total Games: ${stats['totalGames']}'),
            Text('Played Modes: ${stats['playedModes'].length}'),
            Text('Played Categories: ${stats['playedCategories'].length}'),
            Text('Played Difficulties: ${stats['playedDifficulties'].length}'),
            Text('Night Games: ${stats['nightGames']}'),
            Text('Morning Games: ${stats['morningGames']}'),
            Text('Speed Games: ${stats['speedGames']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 