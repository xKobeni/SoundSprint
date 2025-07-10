import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/user_preferences.dart';

class DifficultyProgressionManager {
  static const String _userLevelKey = 'userLevel';
  static const String _userExperienceKey = 'userExperience';
  static const String _unlockedDifficultiesKey = 'unlockedDifficulties';
  static const String _performanceHistoryKey = 'performanceHistory';

  // Experience required for each level
  static const List<int> _experienceRequirements = [
    0,    // Level 1 (Easy unlocked by default)
    100,  // Level 2 (Medium unlocked)
    300,  // Level 3 (Hard unlocked)
    600,  // Level 4 (Expert unlocked)
    1000, // Level 5 (Master unlocked)
  ];

  // Difficulty progression map
  static const Map<String, List<String>> _difficultyProgression = {
    'easy': ['easy'],
    'medium': ['easy', 'medium'],
    'hard': ['easy', 'medium', 'hard'],
    'expert': ['easy', 'medium', 'hard', 'expert'],
    'master': ['easy', 'medium', 'hard', 'expert', 'master'],
  };

  /// Initialize user progression
  static Future<void> initializeProgression() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_userLevelKey)) {
      await prefs.setInt(_userLevelKey, 1);
      await prefs.setInt(_userExperienceKey, 0);
      await prefs.setStringList(_unlockedDifficultiesKey, ['easy']);
    }
  }

  /// Get current user level
  static Future<int> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userLevelKey) ?? 1;
  }

  /// Get current user experience
  static Future<int> getUserExperience() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userExperienceKey) ?? 0;
  }

  /// Get unlocked difficulties
  static Future<List<String>> getUnlockedDifficulties() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedDifficultiesKey) ?? ['easy'];
  }

  /// Update progression based on game performance
  static Future<Map<String, dynamic>> updateProgression({
    required int score,
    required int totalQuestions,
    required String difficulty,
    required int playtimeSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Calculate experience gained
    final accuracy = score / totalQuestions;
    final baseExperience = _calculateBaseExperience(score, totalQuestions, difficulty);
    final bonusExperience = _calculateBonusExperience(accuracy, playtimeSeconds);
    final totalExperience = baseExperience + bonusExperience;
    
    // Debug logging
    debugPrint('=== EXPERIENCE CALCULATION DEBUG ===');
    debugPrint('Score: $score, Total: $totalQuestions, Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%');
    debugPrint('Difficulty: $difficulty, Playtime: ${playtimeSeconds}s');
    debugPrint('Base Experience: $baseExperience');
    debugPrint('Bonus Experience: $bonusExperience');
    debugPrint('Total Experience Gained: $totalExperience');
    
    // Update experience
    final currentExperience = prefs.getInt(_userExperienceKey) ?? 0;
    final newExperience = currentExperience + totalExperience;
    await prefs.setInt(_userExperienceKey, newExperience);
    
    debugPrint('Previous Experience: $currentExperience');
    debugPrint('New Total Experience: $newExperience');
    
    // Check for level up
    final currentLevel = prefs.getInt(_userLevelKey) ?? 1;
    final newLevel = _calculateLevel(newExperience);
    final leveledUp = newLevel > currentLevel;
    
    debugPrint('Previous Level: $currentLevel');
    debugPrint('New Level: $newLevel');
    debugPrint('Leveled Up: $leveledUp');
    
    if (leveledUp) {
      await prefs.setInt(_userLevelKey, newLevel);
      // Sync with UserPreferences
      await UserPreferences().setLevel(newLevel);
      debugPrint('Level updated in SharedPreferences and UserPreferences');
    }
    
    // Update unlocked difficulties
    final unlockedDifficulties = await _updateUnlockedDifficulties(newLevel, prefs);
    
    // Save performance history
    await _savePerformanceHistory(score, totalQuestions, difficulty, accuracy, prefs);
    
    final result = {
      'experienceGained': totalExperience,
      'newExperience': newExperience,
      'leveledUp': leveledUp,
      'oldLevel': currentLevel,
      'newLevel': newLevel,
      'unlockedDifficulties': unlockedDifficulties,
      'accuracy': accuracy,
    };
    
    debugPrint('=== END EXPERIENCE DEBUG ===');
    debugPrint('Returning result: $result');
    
    return result;
  }

  /// Calculate base experience based on score and difficulty
  static int _calculateBaseExperience(int score, int totalQuestions, String difficulty) {
    final accuracy = score / totalQuestions;
    final difficultyMultiplier = _getDifficultyMultiplier(difficulty);
    
    return (accuracy * 50 * difficultyMultiplier).round();
  }

  /// Calculate bonus experience based on accuracy and playtime
  static int _calculateBonusExperience(double accuracy, int playtimeSeconds) {
    int bonus = 0;
    
    // Accuracy bonus
    if (accuracy >= 0.9) bonus += 25;
    else if (accuracy >= 0.8) bonus += 15;
    else if (accuracy >= 0.7) bonus += 10;
    
    // Speed bonus (faster completion = more bonus)
    if (playtimeSeconds <= 60) bonus += 20;
    else if (playtimeSeconds <= 120) bonus += 10;
    
    return bonus;
  }

  /// Public method for testing experience calculation
  static int calculateBaseExperience(int score, int totalQuestions, String difficulty) {
    return _calculateBaseExperience(score, totalQuestions, difficulty);
  }

  /// Public method for testing bonus experience calculation
  static int calculateBonusExperience(double accuracy, int playtimeSeconds) {
    return _calculateBonusExperience(accuracy, playtimeSeconds);
  }

  /// Get difficulty multiplier for experience calculation
  static double _getDifficultyMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return 1.0;
      case 'medium': return 1.5;
      case 'hard': return 2.0;
      case 'expert': return 2.5;
      case 'master': return 3.0;
      default: return 1.0;
    }
  }

  /// Calculate level based on experience 2550
  static int _calculateLevel(int experience) {
    // Use defined requirements for first levels
    for (int i = _experienceRequirements.length - 1; i >= 0; i--) {
      if (experience >= _experienceRequirements[i]) {
        return i + 1;
      }
    }
    
    // If experience is less than the first requirement, return level 1
    if (experience < _experienceRequirements.first) {
      return 1;
    }
    
    // Quadratic scaling for infinite levels beyond the defined requirements
    int level = _experienceRequirements.length;
    while (experience >= 100 * (level + 1) * (level + 1)) {
      level++;
    }
    return level + 1;
  }

  /// Update unlocked difficulties based on level
  static Future<List<String>> _updateUnlockedDifficulties(int level, SharedPreferences prefs) async {
    final levelKey = level > 5 ? 'master' : ['easy', 'medium', 'hard', 'expert', 'master'][level - 1];
    final unlockedDifficulties = _difficultyProgression[levelKey] ?? ['easy'];
    
    await prefs.setStringList(_unlockedDifficultiesKey, unlockedDifficulties);
    return unlockedDifficulties;
  }

  /// Save performance history for analytics
  static Future<void> _savePerformanceHistory(
    int score,
    int totalQuestions,
    String difficulty,
    double accuracy,
    SharedPreferences prefs,
  ) async {
    final historyJson = prefs.getString(_performanceHistoryKey) ?? '[]';
    List<Map<String, dynamic>> history = [];
    
    try {
      history = List<Map<String, dynamic>>.from(json.decode(historyJson));
    } catch (e) {
      history = [];
    }
    
    // Keep only last 50 games
    if (history.length >= 50) {
      history = history.sublist(history.length - 49);
    }
    
    history.add({
      'date': DateTime.now().toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'accuracy': accuracy,
    });
    
    await prefs.setString(_performanceHistoryKey, json.encode(history));
  }

  /// Get performance analytics
  static Future<Map<String, dynamic>> getPerformanceAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_performanceHistoryKey) ?? '[]';
    
    try {
      final history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      
      if (history.isEmpty) {
        return {
          'averageAccuracy': 0.0,
          'bestAccuracy': 0.0,
          'gamesPlayed': 0,
          'favoriteDifficulty': 'easy',
        };
      }
      
      // Calculate analytics
      final accuracies = history.map((h) => h['accuracy'] as double).toList();
      final averageAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
      final bestAccuracy = accuracies.reduce((a, b) => a > b ? a : b);
      
      // Find favorite difficulty
      final difficultyCounts = <String, int>{};
      for (final game in history) {
        final difficulty = game['difficulty'] as String;
        difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1;
      }
      
      final favoriteDifficulty = difficultyCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      return {
        'averageAccuracy': averageAccuracy,
        'bestAccuracy': bestAccuracy,
        'gamesPlayed': history.length,
        'favoriteDifficulty': favoriteDifficulty,
      };
    } catch (e) {
      return {
        'averageAccuracy': 0.0,
        'bestAccuracy': 0.0,
        'gamesPlayed': 0,
        'favoriteDifficulty': 'easy',
      };
    }
  }

  /// Get experience needed for next level
  static Future<int> getExperienceForNextLevel() async {
    final currentExperience = await getUserExperience();
    final currentLevel = await getUserLevel();
    
    if (currentLevel >= _experienceRequirements.length) {
      return 0; // Max level reached
    }
    
    final requiredExperience = _experienceRequirements[currentLevel];
    final neededExperience = requiredExperience - currentExperience;
    return neededExperience > 0 ? neededExperience : 0;
  }

  /// Check if user can play a specific difficulty
  static Future<bool> canPlayDifficulty(String difficulty) async {
    final unlockedDifficulties = await getUnlockedDifficulties();
    return unlockedDifficulties.contains(difficulty.toLowerCase());
  }

  /// Get current experience, current level, and next level XP requirement
  static Future<Map<String, int>> getLevelProgression() async {
    final prefs = await SharedPreferences.getInstance();
    final experience = prefs.getInt(_userExperienceKey) ?? 0;
    final level = prefs.getInt(_userLevelKey) ?? 1;
    int currentLevelXp = 0;
    int nextLevelXp = 0;
    
    // Calculate current level XP requirement
    if (level <= _experienceRequirements.length) {
      currentLevelXp = _experienceRequirements[level - 1];
    } else {
      currentLevelXp = 100 * (level - 1) * (level - 1);
    }
    
    // Calculate next level XP requirement
    if (level < _experienceRequirements.length) {
      nextLevelXp = _experienceRequirements[level];
    } else {
      nextLevelXp = 100 * level * level;
    }
    
    return {
      'experience': experience,
      'currentLevelXp': currentLevelXp,
      'nextLevelXp': nextLevelXp,
      'level': level,
    };
  }

  /// Test method to verify leveling logic (for debugging)
  static void testLevelingLogic() {
    debugPrint('Testing leveling logic...');
    
    // Test cases
    final testCases = [0, 50, 100, 200, 300, 500, 600, 800, 1000, 1200];
    
    for (final experience in testCases) {
      final level = _calculateLevel(experience);
      debugPrint('Experience: $experience -> Level: $level');
      
      // Verify no negative values in progression calculation
      int currentLevelXp = 0;
      int nextLevelXp = 0;
      
      if (level <= _experienceRequirements.length) {
        currentLevelXp = _experienceRequirements[level - 1];
      } else {
        currentLevelXp = 100 * (level - 1) * (level - 1);
      }
      
      if (level < _experienceRequirements.length) {
        nextLevelXp = _experienceRequirements[level];
      } else {
        nextLevelXp = 100 * level * level;
      }
      
      final xpProgress = (experience - currentLevelXp).clamp(0, nextLevelXp - currentLevelXp);
      debugPrint('  Current Level XP: $currentLevelXp, Next Level XP: $nextLevelXp, Progress: $xpProgress');
      
      if (xpProgress < 0) {
        debugPrint('  ERROR: Negative XP progress detected!');
      }
    }
  }
} 