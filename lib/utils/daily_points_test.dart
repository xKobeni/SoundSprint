import 'package:flutter/foundation.dart';
import 'daily_points_manager.dart';

class DailyPointsTest {
  /// Test the daily points system
  static Future<void> testDailyPoints() async {
    if (!kDebugMode) return;
    
    print('🧪 Testing Daily Points System...');
    
    try {
      // Initialize
      await DailyPointsManager.initialize();
      print('✅ Daily Points Manager initialized');
      
      // Get today's points
      final todayPoints = await DailyPointsManager.getTodayPoints();
      print('📊 Today\'s points: $todayPoints');
      
      // Add some test points
      final addedPoints = await DailyPointsManager.addTodayPoints(100);
      print('➕ Added 100 points, total today: $addedPoints');
      
      // Get daily goal
      final dailyGoal = await DailyPointsManager.getDailyGoal();
      print('🎯 Daily goal: $dailyGoal');
      
      // Get progress
      final progress = await DailyPointsManager.getDailyGoalProgress();
      print('📈 Progress: ${(progress * 100).toStringAsFixed(1)}%');
      
      // Get weekly history
      final weeklyHistory = await DailyPointsManager.getWeeklyHistory();
      print('📅 Weekly history: ${weeklyHistory.length} days');
      
      // Get average daily points
      final averagePoints = await DailyPointsManager.getAverageDailyPoints();
      print('📊 Average daily points: ${averagePoints.toStringAsFixed(1)}');
      
      // Get best daily points
      final bestPoints = await DailyPointsManager.getBestDailyPoints();
      print('🏆 Best daily points: $bestPoints');
      
      print('✅ Daily Points System test completed successfully!');
      
    } catch (e) {
      print('❌ Daily Points System test failed: $e');
    }
  }
  
  /// Test daily reset functionality
  static Future<void> testDailyReset() async {
    if (!kDebugMode) return;
    
    print('🔄 Testing Daily Reset...');
    
    try {
      // Check if today is reset
      final isReset = await DailyPointsManager.isTodayReset();
      print('🔄 Is today reset: $isReset');
      
      // Get today's points after potential reset
      final todayPoints = await DailyPointsManager.getTodayPoints();
      print('📊 Today\'s points after reset check: $todayPoints');
      
      print('✅ Daily Reset test completed!');
      
    } catch (e) {
      print('❌ Daily Reset test failed: $e');
    }
  }
} 