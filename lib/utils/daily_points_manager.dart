import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPointsManager {
  static const String _dailyPointsKey = 'dailyPoints';
  static const String _lastPointsDateKey = 'lastPointsDate';
  static const String _dailyPointsHistoryKey = 'dailyPointsHistory';

  /// Initialize daily points
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastPointsDate = prefs.getString(_lastPointsDateKey);
    
    // Reset daily points if it's a new day
    if (lastPointsDate != todayString) {
      await prefs.setInt(_dailyPointsKey, 0);
      await prefs.setString(_lastPointsDateKey, todayString);
    }
  }

  /// Get today's points earned
  static Future<int> getTodayPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastPointsDate = prefs.getString(_lastPointsDateKey);
    
    // Reset if it's a new day
    if (lastPointsDate != todayString) {
      await prefs.setInt(_dailyPointsKey, 0);
      await prefs.setString(_lastPointsDateKey, todayString);
      return 0;
    }
    
    return prefs.getInt(_dailyPointsKey) ?? 0;
  }

  /// Add points for today
  static Future<int> addTodayPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastPointsDate = prefs.getString(_lastPointsDateKey);
    
    // Reset if it's a new day
    if (lastPointsDate != todayString) {
      await prefs.setInt(_dailyPointsKey, points);
      await prefs.setString(_lastPointsDateKey, todayString);
      await _saveDailyPointsHistory(todayString, points);
      return points;
    }
    
    final currentPoints = prefs.getInt(_dailyPointsKey) ?? 0;
    final newPoints = currentPoints + points;
    await prefs.setInt(_dailyPointsKey, newPoints);
    await _saveDailyPointsHistory(todayString, newPoints);
    
    return newPoints;
  }

  /// Save daily points to history
  static Future<void> _saveDailyPointsHistory(String date, int points) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_dailyPointsHistoryKey) ?? '{}';
    Map<String, dynamic> history = {};
    
    try {
      history = Map<String, dynamic>.from(json.decode(historyJson));
    } catch (e) {
      history = {};
    }
    
    history[date] = points;
    
    // Keep only last 30 days
    if (history.length > 30) {
      final sortedDates = history.keys.toList()..sort();
      final datesToRemove = sortedDates.take(sortedDates.length - 30);
      for (final date in datesToRemove) {
        history.remove(date);
      }
    }
    
    await prefs.setString(_dailyPointsHistoryKey, json.encode(history));
  }

  /// Get daily points history (last 7 days)
  static Future<List<Map<String, dynamic>>> getWeeklyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_dailyPointsHistoryKey) ?? '{}';
    Map<String, dynamic> history = {};
    
    try {
      history = Map<String, dynamic>.from(json.decode(historyJson));
    } catch (e) {
      return [];
    }
    
    final today = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final points = history[dateString] ?? 0;
      
      weeklyData.add({
        'date': dateString,
        'points': points,
        'dayName': _getDayName(date.weekday),
      });
    }
    
    return weeklyData;
  }

  /// Get day name from weekday number
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  /// Get average daily points (last 7 days)
  static Future<double> getAverageDailyPoints() async {
    final weeklyHistory = await getWeeklyHistory();
    if (weeklyHistory.isEmpty) return 0.0;
    
    final totalPoints = weeklyHistory.fold<int>(0, (sum, day) => sum + (day['points'] as int));
    return totalPoints / weeklyHistory.length;
  }

  /// Get best daily points (last 30 days)
  static Future<int> getBestDailyPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_dailyPointsHistoryKey) ?? '{}';
    Map<String, dynamic> history = {};
    
    try {
      history = Map<String, dynamic>.from(json.decode(historyJson));
    } catch (e) {
      return 0;
    }
    
    if (history.isEmpty) return 0;
    
    final points = history.values.map((p) => p as int).toList();
    return points.reduce((a, b) => a > b ? a : b);
  }

  /// Check if today's points have been reset
  static Future<bool> isTodayReset() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastPointsDate = prefs.getString(_lastPointsDateKey);
    return lastPointsDate != todayString;
  }

  /// Get daily points goal (can be customized)
  static Future<int> getDailyGoal() async {
    // For now, return a fixed goal of 500 points
    // This could be made dynamic based on user level or preferences
    return 500;
  }

  /// Get progress towards daily goal
  static Future<double> getDailyGoalProgress() async {
    final todayPoints = await getTodayPoints();
    final dailyGoal = await getDailyGoal();
    
    if (dailyGoal <= 0) return 0.0;
    return (todayPoints / dailyGoal).clamp(0.0, 1.0);
  }

  /// Reset daily points (for testing purposes)
  static Future<void> resetDailyPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyPointsKey, 0);
  }

  /// Get daily points statistics
  static Future<Map<String, dynamic>> getDailyStats() async {
    final todayPoints = await getTodayPoints();
    final dailyGoal = await getDailyGoal();
    final progress = await getDailyGoalProgress();
    final averagePoints = await getAverageDailyPoints();
    final bestPoints = await getBestDailyPoints();
    final weeklyHistory = await getWeeklyHistory();
    
    return {
      'todayPoints': todayPoints,
      'dailyGoal': dailyGoal,
      'progress': progress,
      'averagePoints': averagePoints,
      'bestPoints': bestPoints,
      'weeklyHistory': weeklyHistory,
    };
  }
} 