import 'package:flutter/foundation.dart';
import 'daily_challenge_manager.dart';

class DailyChallengeTest {
  /// Test the daily challenges system
  static Future<void> testDailyChallenges() async {
    if (!kDebugMode) return;
    
    debugPrint('🧪 Testing Daily Challenges System...');
    
    try {
      // Force generate new challenges
      final challenges = await DailyChallengeManager.forceGenerateChallenges();
      debugPrint('✅ Generated ${challenges.length} challenges');
      
      for (final challenge in challenges) {
        debugPrint('📋 Challenge: ${challenge.title}');
        debugPrint('   Type: ${challenge.type}, Target: ${challenge.target}');
        debugPrint('   Description: ${challenge.description}');
        debugPrint('   Reward: ${challenge.rewardAmount} ${challenge.reward}');
      }
      
      // Test challenge progress update
      debugPrint('\n🔄 Testing challenge progress update...');
      final completedChallenges = await DailyChallengeManager.updateProgress(
        score: 8,
        totalQuestions: 10,
        category: 'Mixed',
        difficulty: 'Medium',
        currentStreak: 1,
        todayGamesPlayed: 1,
      );
      
      debugPrint('✅ Completed ${completedChallenges.length} challenges');
      
      // Get current challenges
      final currentChallenges = await DailyChallengeManager.getCurrentDailyChallenges();
      debugPrint('📊 Current challenges: ${currentChallenges.length}');
      
      for (final challenge in currentChallenges) {
        debugPrint('   ${challenge.title}: ${challenge.currentProgress}/${challenge.target} (${challenge.isCompleted ? '✅' : '⏳'})');
      }
      
      debugPrint('✅ Daily Challenges System test completed successfully!');
      
    } catch (e) {
      debugPrint('❌ Daily Challenges System test failed: $e');
    }
  }
  
  /// Test specific challenge types
  static Future<void> testSpecificChallenges() async {
    if (!kDebugMode) return;
    
    debugPrint('🧪 Testing Specific Challenge Types...');
    
    try {
      // Reset challenges first
      await DailyChallengeManager.resetDailyChallenges();
      
      // Test score challenge
      debugPrint('\n🎯 Testing Score Challenge...');
      await DailyChallengeManager.updateProgress(
        score: 9,
        totalQuestions: 10,
        category: 'Mixed',
        difficulty: 'Medium',
        currentStreak: 1,
        todayGamesPlayed: 1,
      );
      
      // Test accuracy challenge
      debugPrint('\n🎯 Testing Accuracy Challenge...');
      await DailyChallengeManager.updateProgress(
        score: 9,
        totalQuestions: 10,
        category: 'Mixed',
        difficulty: 'Medium',
        currentStreak: 1,
        todayGamesPlayed: 1,
      );
      
      // Test games challenge
      debugPrint('\n🎮 Testing Games Challenge...');
      await DailyChallengeManager.updateProgress(
        score: 5,
        totalQuestions: 10,
        category: 'Mixed',
        difficulty: 'Easy',
        currentStreak: 0,
        todayGamesPlayed: 3,
      );
      
      // Test difficulty challenge
      debugPrint('\n💪 Testing Difficulty Challenge...');
      await DailyChallengeManager.updateProgress(
        score: 7,
        totalQuestions: 10,
        category: 'Mixed',
        difficulty: 'Hard',
        currentStreak: 1,
        todayGamesPlayed: 1,
      );
      
      // Test category challenge
      debugPrint('\n🎵 Testing Category Challenge...');
      await DailyChallengeManager.updateProgress(
        score: 6,
        totalQuestions: 10,
        category: 'Music',
        difficulty: 'Medium',
        currentStreak: 1,
        todayGamesPlayed: 1,
      );
      
      debugPrint('✅ Specific Challenge Types test completed!');
      
    } catch (e) {
      debugPrint('❌ Specific Challenge Types test failed: $e');
    }
  }
} 