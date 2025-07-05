import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsManager {
  static const String _gamesPlayedKey = 'gamesPlayed';
  static const String _highScoreKey = 'highScore';
  static const String _totalScoreKey = 'totalScore';
  static const String _totalQuestionsKey = 'totalQuestions';
  static const String _highestStreakKey = 'highestStreak';
  static const String _currentStreakKey = 'currentStreak';
  static const String _totalPlaytimeKey = 'totalPlaytime';
  static const String _categoryStatsKey = 'categoryStats';
  static const String _difficultyStatsKey = 'difficultyStats';
  static const String _mostMissedQuestionsKey = 'mostMissedQuestions';

  /// Updates stats after completing a game
  static Future<void> updateGameStats({
    required int score,
    required int totalQuestions,
    required int playtimeSeconds,
    required String category,
    required String difficulty,
    required List<Map<String, dynamic>> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update basic stats
    final gamesPlayed = (prefs.getInt(_gamesPlayedKey) ?? 0) + 1;
    final currentHighScore = prefs.getInt(_highScoreKey) ?? 0;
    final totalScore = (prefs.getInt(_totalScoreKey) ?? 0) + score;
    final totalQuestionsAnswered = (prefs.getInt(_totalQuestionsKey) ?? 0) + totalQuestions;
    final totalPlaytime = (prefs.getInt(_totalPlaytimeKey) ?? 0) + playtimeSeconds;
    
    // Calculate accuracy
    final correctAnswers = answers.where((a) => a['userAnswer'] == a['correctAnswer']).length;
    final accuracy = totalQuestionsAnswered > 0 ? correctAnswers / totalQuestionsAnswered : 0.0;
    
    // Update streak
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final newStreak = score == totalQuestions ? currentStreak + 1 : 0;
    final highestStreak = prefs.getInt(_highestStreakKey) ?? 0;
    
    // Save basic stats
    await prefs.setInt(_gamesPlayedKey, gamesPlayed);
    await prefs.setInt(_totalScoreKey, totalScore);
    await prefs.setInt(_totalQuestionsKey, totalQuestionsAnswered);
    await prefs.setInt(_totalPlaytimeKey, totalPlaytime);
    await prefs.setDouble('accuracy', accuracy);
    await prefs.setInt(_currentStreakKey, newStreak);
    
    // Update high score if needed
    if (score > currentHighScore) {
      await prefs.setInt(_highScoreKey, score);
    }
    
    // Update highest streak if needed
    if (newStreak > highestStreak) {
      await prefs.setInt(_highestStreakKey, newStreak);
    }
    
    // Update category stats
    await _updateCategoryStats(category, score, totalQuestions, prefs);
    
    // Update difficulty stats
    await _updateDifficultyStats(difficulty, score, totalQuestions, prefs);
    
    // Update most missed questions
    await _updateMostMissedQuestions(answers, prefs);
  }

  /// Updates category-specific statistics
  static Future<void> _updateCategoryStats(
    String category,
    int score,
    int totalQuestions,
    SharedPreferences prefs,
  ) async {
    final categoryStatsJson = prefs.getString(_categoryStatsKey) ?? '{}';
    Map<String, dynamic> categoryStats = {};
    
    try {
      categoryStats = Map<String, dynamic>.from(json.decode(categoryStatsJson));
    } catch (e) {
      categoryStats = {};
    }
    
    if (!categoryStats.containsKey(category)) {
      categoryStats[category] = {
        'gamesPlayed': 0,
        'totalScore': 0,
        'totalQuestions': 0,
        'highScore': 0,
      };
    }
    
    final catStats = categoryStats[category] as Map<String, dynamic>;
    catStats['gamesPlayed'] = (catStats['gamesPlayed'] ?? 0) + 1;
    catStats['totalScore'] = (catStats['totalScore'] ?? 0) + score;
    catStats['totalQuestions'] = (catStats['totalQuestions'] ?? 0) + totalQuestions;
    
    if (score > (catStats['highScore'] ?? 0)) {
      catStats['highScore'] = score;
    }
    
    await prefs.setString(_categoryStatsKey, json.encode(categoryStats));
  }

  /// Updates difficulty-specific statistics
  static Future<void> _updateDifficultyStats(
    String difficulty,
    int score,
    int totalQuestions,
    SharedPreferences prefs,
  ) async {
    final difficultyStatsJson = prefs.getString(_difficultyStatsKey) ?? '{}';
    Map<String, dynamic> difficultyStats = {};
    
    try {
      difficultyStats = Map<String, dynamic>.from(json.decode(difficultyStatsJson));
    } catch (e) {
      difficultyStats = {};
    }
    
    if (!difficultyStats.containsKey(difficulty)) {
      difficultyStats[difficulty] = {
        'gamesPlayed': 0,
        'totalScore': 0,
        'totalQuestions': 0,
        'highScore': 0,
      };
    }
    
    final diffStats = difficultyStats[difficulty] as Map<String, dynamic>;
    diffStats['gamesPlayed'] = (diffStats['gamesPlayed'] ?? 0) + 1;
    diffStats['totalScore'] = (diffStats['totalScore'] ?? 0) + score;
    diffStats['totalQuestions'] = (diffStats['totalQuestions'] ?? 0) + totalQuestions;
    
    if (score > (diffStats['highScore'] ?? 0)) {
      diffStats['highScore'] = score;
    }
    
    await prefs.setString(_difficultyStatsKey, json.encode(difficultyStats));
  }

  /// Updates most missed questions tracking
  static Future<void> _updateMostMissedQuestions(
    List<Map<String, dynamic>> answers,
    SharedPreferences prefs,
  ) async {
    final missedQuestionsJson = prefs.getString(_mostMissedQuestionsKey) ?? '{}';
    Map<String, dynamic> missedQuestions = {};
    
    try {
      missedQuestions = Map<String, dynamic>.from(json.decode(missedQuestionsJson));
    } catch (e) {
      missedQuestions = {};
    }
    
    for (final answer in answers) {
      if (answer['userAnswer'] != answer['correctAnswer']) {
        final questionKey = answer['question'] ?? 'Unknown';
        missedQuestions[questionKey] = (missedQuestions[questionKey] ?? 0) + 1;
      }
    }
    
    await prefs.setString(_mostMissedQuestionsKey, json.encode(missedQuestions));
  }

  /// Gets all current stats
  static Future<Map<String, dynamic>> getAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'gamesPlayed': prefs.getInt(_gamesPlayedKey) ?? 0,
      'highScore': prefs.getInt(_highScoreKey) ?? 0,
      'totalScore': prefs.getInt(_totalScoreKey) ?? 0,
      'totalQuestions': prefs.getInt(_totalQuestionsKey) ?? 0,
      'accuracy': prefs.getDouble('accuracy') ?? 0.0,
      'highestStreak': prefs.getInt(_highestStreakKey) ?? 0,
      'currentStreak': prefs.getInt(_currentStreakKey) ?? 0,
      'totalPlaytime': prefs.getInt(_totalPlaytimeKey) ?? 0,
      'averageScore': _calculateAverageScore(
        prefs.getInt(_totalScoreKey) ?? 0,
        prefs.getInt(_gamesPlayedKey) ?? 0,
      ),
    };
  }

  /// Calculates average score
  static double _calculateAverageScore(int totalScore, int gamesPlayed) {
    return gamesPlayed > 0 ? totalScore / gamesPlayed : 0.0;
  }

  /// Gets most missed questions
  static Future<String> getMostMissedQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    final missedQuestionsJson = prefs.getString(_mostMissedQuestionsKey) ?? '{}';
    
    try {
      final missedQuestions = Map<String, dynamic>.from(json.decode(missedQuestionsJson));
      
      if (missedQuestions.isEmpty) {
        return 'No missed questions yet';
      }
      
      String mostMissed = '';
      int maxCount = 0;
      
      missedQuestions.forEach((question, count) {
        if (count > maxCount) {
          maxCount = count;
          mostMissed = question;
        }
      });
      
      return mostMissed;
    } catch (e) {
      return 'No missed questions yet';
    }
  }

  /// Resets all stats
  static Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamesPlayedKey);
    await prefs.remove(_highScoreKey);
    await prefs.remove(_totalScoreKey);
    await prefs.remove(_totalQuestionsKey);
    await prefs.remove(_highestStreakKey);
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_totalPlaytimeKey);
    await prefs.remove('accuracy');
    await prefs.remove(_categoryStatsKey);
    await prefs.remove(_difficultyStatsKey);
    await prefs.remove(_mostMissedQuestionsKey);
  }

  /// Gets all category stats
  static Future<Map<String, dynamic>> getCategoryStats() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryStatsJson = prefs.getString(_categoryStatsKey) ?? '{}';
    try {
      return Map<String, dynamic>.from(json.decode(categoryStatsJson));
    } catch (e) {
      return {};
    }
  }

  /// Gets all difficulty stats
  static Future<Map<String, dynamic>> getDifficultyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyStatsJson = prefs.getString(_difficultyStatsKey) ?? '{}';
    try {
      return Map<String, dynamic>.from(json.decode(difficultyStatsJson));
    } catch (e) {
      return {};
    }
  }
} 