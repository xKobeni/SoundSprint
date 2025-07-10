import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/main_navigation_page.dart';
import 'pages/game_page.dart';
import 'pages/category_selection_page.dart';
import 'pages/result_page.dart';
import 'pages/stats_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'utils/managers/audio_manager.dart';
import 'utils/managers/network_manager.dart';
import 'utils/managers/accessibility_manager.dart';
import 'utils/managers/settings_provider.dart';
import 'utils/managers/achievement_manager.dart';
import 'utils/managers/daily_points_manager.dart';
import 'utils/managers/difficulty_progression_manager.dart';
import 'utils/managers/user_preferences.dart';
import 'utils/tests/audio_test.dart';
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
            '/category-selection': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return CategorySelectionPage(
                gameMode: args?['gameMode'] as String? ?? '',
                gameModeName: args?['gameModeName'] as String? ?? '',
              );
            },
            '/result': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return ResultPage(
                score: args?['score'] as int? ?? 0,
                total: args?['total'] as int? ?? 0,
                answers: args?['answers'] as List<Map<String, dynamic>>? ?? [],
                progression: args?['progression'] as Map<String, dynamic>?,
                modeSpecificPoints: args?['modeSpecificPoints'] as int? ?? 0,
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
