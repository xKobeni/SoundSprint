import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/main_navigation_page.dart';
import 'pages/game_page.dart';
import 'pages/result_page.dart';
import 'pages/stats_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'utils/audio_manager.dart';
import 'utils/network_manager.dart';
import 'utils/accessibility_manager.dart';
import 'utils/settings_provider.dart';
import 'utils/achievement_manager.dart';
import 'utils/daily_challenge_manager.dart';
import 'utils/daily_points_manager.dart';
import 'utils/daily_challenge_test.dart';
import 'utils/difficulty_progression_manager.dart';
import 'utils/user_preferences.dart';
import 'utils/audio_test.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize managers in parallel for better performance
  await Future.wait([
    AudioManager().initialize(),
    NetworkManager().initialize(),
    AccessibilityManager().initialize(),
    SettingsProvider().initialize(),
    UserPreferences().initialize(),
    AchievementManager.initializeAchievements(),
    DailyChallengeManager.generateDailyChallenges(),
    DailyPointsManager.initialize(),
    DifficultyProgressionManager.initializeProgression(),
  ]);
  
  // Test leveling logic for debugging (remove in production)
  if (kDebugMode) {
    DifficultyProgressionManager.testLevelingLogic();
  }
  
  // Test audio functionality for debugging (remove in production)
  if (kDebugMode) {
    await AudioTest.testDogBark();
  }
  
  // Test daily points system for debugging (remove in production)
  // Removed: if (kDebugMode) {
  //   await DailyPointsTest.testDailyPoints();
  //   await DailyPointsTest.testDailyReset();
  // }
  
  // Test daily challenges system for debugging (remove in production)
  if (kDebugMode) {
    await DailyChallengeTest.testDailyChallenges();
  }
  

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsProvider(),
      builder: (context, child) {
        return MaterialApp(
          title: 'SoundSprint',
          theme: SettingsProvider().currentTheme,
          initialRoute: '/splash',
          debugShowCheckedModeBanner: false,
          routes: {
            '/splash': (context) => const SplashPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/main': (context) => const MainNavigationPage(),
            '/game': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return GamePage(
                difficulty: args?['difficulty'] as String?,
                category: args?['category'] as String?,
                timeLimit: args?['timeLimit'] as int?,
              );
            },
            '/result': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return ResultPage(
                score: args?['score'] as int? ?? 0,
                total: args?['total'] as int? ?? 0,
                answers: args?['answers'] as List<Map<String, dynamic>>? ?? [],
                progression: args?['progression'] as Map<String, dynamic>?,
              );
            },
            '/stats': (context) => const StatsPage(),
            '/profile': (context) => const ProfilePage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
