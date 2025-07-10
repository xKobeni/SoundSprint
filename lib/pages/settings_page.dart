import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/managers/stats_manager.dart';
import '../utils/managers/audio_manager.dart';
import '../utils/managers/tutorial_manager.dart';
import '../utils/managers/settings_provider.dart';
import '../widgets/sound_preview_widget.dart';
import '../widgets/tutorial_overlay.dart';
import 'profile_page.dart';
import 'stats_page.dart';
import 'achievements_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/managers/user_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Settings are already loaded in SettingsProvider
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _showErrorDialog('Failed to load settings: $e');
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

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will reset your profile, stats, and settings. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Data'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      try {
        await StatsManager.resetAllStats();
        await SettingsProvider().clearAllSettings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully')),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to clear data: $e');
      }
    }
  }

  void _showHelp() {
    final helpContent = TutorialManager.getHelpContent();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FAQ Section
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...helpContent['faq'].map<Widget>((faq) => ExpansionTile(
                  title: Text(faq['question']),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(faq['answer']),
                    ),
                  ],
                )).toList(),
                
                const SizedBox(height: 20),
                
                // Tips Section
                const Text(
                  'Tips for Better Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...helpContent['tips'].map<Widget>((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 20),
                
                // Troubleshooting Section
                const Text(
                  'Troubleshooting',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...helpContent['troubleshooting'].map<Widget>((issue) => ExpansionTile(
                  title: Text(issue['issue']),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(issue['solution']),
                    ),
                  ],
                )).toList(),
              ],
            ),
          ),
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

  Future<void> _resetTutorials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Tutorials?'),
        content: const Text('This will show tutorials again for all game modes. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset Tutorials'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      try {
        await TutorialManager.resetTutorials();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tutorials reset successfully')),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to reset tutorials: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return TutorialOverlay(
      tutorialKey: 'settings',
      steps: TutorialHelper.getSettingsTutorialSteps(),
      child: Scaffold(
        appBar: AppBar(
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
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 24),
                // User Settings (no Data Management child)
                _buildSettingsCard(
                  icon: Icons.person,
                  title: 'User Settings',
                  subtitle: 'Manage your profile and data',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Statistics
                _buildSettingsCard(
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  subtitle: 'View your stats',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StatsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Achievements
                _buildSettingsCard(
                  icon: Icons.emoji_events,
                  title: 'Achievements',
                  subtitle: 'Track your accomplishments',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AchievementsPage(showBottomNav: true)),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Help & Support
                _buildSettingsCard(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and find answers',
                  onTap: _showHelp,
                ),
                const SizedBox(height: 16),
                // Reset Tutorials
                _buildSettingsCard(
                  icon: Icons.refresh,
                  title: 'Reset Tutorials',
                  subtitle: 'Show tutorials again for all game modes',
                  onTap: _resetTutorials,
                ),
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
            Icons.settings,
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
                'Settings',
                style: TextStyle(
                  color: Color(0xFF7C5CFC),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Customize your experience',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF7C5CFC), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C5CFC),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFF7C5CFC), size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 