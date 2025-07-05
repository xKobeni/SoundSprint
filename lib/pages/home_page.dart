import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user.dart';
import '../utils/user_preferences.dart';
import '../utils/stats_manager.dart';
import '../utils/audio_test.dart';
import '../widgets/daily_challenges_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  String _displayName = '';
  User? _user;
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
      final user = await _userPreferences.getUser();

      if (mounted) {
        setState(() {
          _stats = stats;
          _user = user;
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

  void _showDailyChallenges() {
    showDialog(
      context: context,
      builder: (context) => const DailyChallengesPopup(),
    );
  }
  
  Future<void> _testAudio() async {
    await AudioTest.testDogBark();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio test completed! Check console for results.'),
          duration: Duration(seconds: 3),
        ),
      );
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
            _buildDailyChallengesCard(),
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
      title: Row(
        children: [
          Stack(
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
          const SizedBox(width: 16),
          Column(
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
              ),
            ],
          ),
        ],
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
              Text(
                '${_stats['totalQuestions'] ?? 0} Questions',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Games Played', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _stats['gamesPlayed'] != null && _stats['gamesPlayed'] > 0
                  ? (_stats['gamesPlayed'] / 10).clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEE6FF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_stats['gamesPlayed'] ?? 0} games completed',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengesCard() {
    return GestureDetector(
      onTap: _showDailyChallenges,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB6B6), Color(0xFF7C5CFC)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Challenges',
                    style: TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete challenges to earn rewards',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
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
              onPressed: () {}, // TODO: Implement View All
              child: const Text('View All', style: TextStyle(color: Color(0xFF7C5CFC))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.person,
          title: 'Famous People',
          subcategories: '12 Subcategories',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.attach_money,
          title: 'Money',
          subcategories: '12 Subcategories',
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildQuizVaultCard(
          icon: Icons.emoji_events,
          title: 'Sports',
          subcategories: '12 Subcategories',
          color: Colors.yellow[700]!,
        ),
      ],
    );
  }

  Widget _buildQuizVaultCard({required IconData icon, required String title, required String subcategories, required Color color}) {
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
            _buildGameCard(icon: Icons.lock, label: 'Quiz Vault'),
            _buildGameCard(icon: Icons.edit, label: 'Guess The Word'),
            _buildGameCard(icon: Icons.check_circle, label: 'True or False'),
            _buildGameCard(icon: Icons.calendar_today, label: 'Daily Quiz'),
          ],
        ),
      ],
    );
  }

  Widget _buildGameCard({required IconData icon, required String label}) {
    return Container(
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
    );
  }
} 