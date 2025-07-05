import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_challenge.dart';
import 'user_preferences.dart';

class DailyChallengeManager {
  static const String _dailyChallengesKey = 'dailyChallenges';
  static const String _lastChallengeDateKey = 'lastChallengeDate';

  // Challenge templates
  static final List<Map<String, dynamic>> _challengeTemplates = [
    {
      'id': 'daily_score_80',
      'title': 'High Achiever',
      'description': 'Score 80% or higher in a game',
      'type': 'score',
      'target': 1,
      'reward': 'Bonus Points',
      'rewardAmount': 50,
    },
    {
      'id': 'daily_games_3',
      'title': 'Daily Grind',
      'description': 'Play 3 games today',
      'type': 'games',
      'target': 3,
      'reward': 'Experience',
      'rewardAmount': 100,
    },
    {
      'id': 'daily_streak_2',
      'title': 'Consistency',
      'description': 'Maintain a 2-game winning streak',
      'type': 'streak',
      'target': 2,
      'reward': 'Streak Bonus',
      'rewardAmount': 75,
    },
    {
      'id': 'daily_accuracy_85',
      'title': 'Sharp Focus',
      'description': 'Achieve 85% accuracy in a game',
      'type': 'accuracy',
      'target': 1,
      'reward': 'Accuracy Bonus',
      'rewardAmount': 60,
    },
    {
      'id': 'daily_sound_games',
      'title': 'Sound Explorer',
      'description': 'Complete 2 sound-based games',
      'type': 'category',
      'target': 2,
      'reward': 'Category Bonus',
      'rewardAmount': 40,
    },
    {
      'id': 'daily_music_games',
      'title': 'Music Lover',
      'description': 'Complete 2 music-based games',
      'type': 'category',
      'target': 2,
      'reward': 'Category Bonus',
      'rewardAmount': 40,
    },
    {
      'id': 'daily_hard_game',
      'title': 'Challenge Seeker',
      'description': 'Complete a hard difficulty game',
      'type': 'difficulty',
      'target': 1,
      'reward': 'Difficulty Bonus',
      'rewardAmount': 80,
    },
  ];

  /// Generate new daily challenges
  static Future<List<DailyChallenge>> generateDailyChallenges() async {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final prefs = await SharedPreferences.getInstance();
    final lastChallengeDate = prefs.getString(_lastChallengeDateKey);
    
    // Check if we need to generate new challenges
    if (lastChallengeDate == todayString) {
      return await getCurrentDailyChallenges();
    }
    
    // Generate 3 random challenges
    final random = Random();
    final selectedTemplates = <Map<String, dynamic>>[];
    final availableTemplates = List<Map<String, dynamic>>.from(_challengeTemplates);
    
    for (int i = 0; i < 3 && availableTemplates.isNotEmpty; i++) {
      final index = random.nextInt(availableTemplates.length);
      selectedTemplates.add(availableTemplates[index]);
      availableTemplates.removeAt(index);
    }
    
    final challenges = selectedTemplates.map((template) {
      return DailyChallenge(
        id: '${template['id']}_${todayString}',
        title: template['title'] as String,
        description: template['description'] as String,
        type: template['type'] as String,
        target: template['target'] as int,
        date: today,
        reward: template['reward'] as String?,
        rewardAmount: template['rewardAmount'] as int?,
      );
    }).toList();
    
    // Save new challenges
    await _saveDailyChallenges(challenges);
    await prefs.setString(_lastChallengeDateKey, todayString);
    
    return challenges;
  }

  /// Get current daily challenges
  static Future<List<DailyChallenge>> getCurrentDailyChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getString(_dailyChallengesKey) ?? '[]';
    
    try {
      final List<dynamic> challengesList = json.decode(challengesJson);
      return challengesList.map((json) => DailyChallenge.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update challenge progress
  static Future<List<DailyChallenge>> updateProgress({
    required int score,
    required int totalQuestions,
    required String category,
    required String difficulty,
    required int currentStreak,
  }) async {
    final challenges = await getCurrentDailyChallenges();
    final updatedChallenges = <DailyChallenge>[];
    final completedChallenges = <DailyChallenge>[];
    
    for (final challenge in challenges) {
      if (challenge.isCompleted) {
        updatedChallenges.add(challenge);
        continue;
      }
      
      int newProgress = challenge.currentProgress;
      bool shouldComplete = false;
      
      switch (challenge.type) {
        case 'score':
          if (score >= (totalQuestions * 0.8)) {
            newProgress = challenge.currentProgress + 1;
            shouldComplete = newProgress >= challenge.target;
          }
          break;
          
        case 'games':
          newProgress = challenge.currentProgress + 1;
          shouldComplete = newProgress >= challenge.target;
          break;
          
        case 'streak':
          if (currentStreak >= challenge.target) {
            newProgress = challenge.target;
            shouldComplete = true;
          }
          break;
          
        case 'accuracy':
          final accuracy = score / totalQuestions;
          if (accuracy >= 0.85) {
            newProgress = challenge.currentProgress + 1;
            shouldComplete = newProgress >= challenge.target;
          }
          break;
          
        case 'category':
          if ((challenge.id.contains('sound') && category == 'sound') ||
              (challenge.id.contains('music') && category == 'music')) {
            newProgress = challenge.currentProgress + 1;
            shouldComplete = newProgress >= challenge.target;
          }
          break;
          
        case 'difficulty':
          if (difficulty == 'hard') {
            newProgress = challenge.currentProgress + 1;
            shouldComplete = newProgress >= challenge.target;
          }
          break;
      }
      
      final updatedChallenge = challenge.copyWith(
        currentProgress: newProgress,
        isCompleted: shouldComplete,
      );
      
      updatedChallenges.add(updatedChallenge);
      
      if (shouldComplete) {
        completedChallenges.add(updatedChallenge);
        // Award points for completed challenge
        if (updatedChallenge.rewardAmount != null && updatedChallenge.rewardAmount! > 0) {
          await UserPreferences().addPoints(updatedChallenge.rewardAmount!);
        }
      }
    }
    
    // Save updated challenges
    await _saveDailyChallenges(updatedChallenges);
    
    return completedChallenges;
  }

  /// Save daily challenges to storage
  static Future<void> _saveDailyChallenges(List<DailyChallenge> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = challenges.map((c) => c.toJson()).toList();
    await prefs.setString(_dailyChallengesKey, json.encode(challengesJson));
  }

  /// Get completed challenges count for today
  static Future<int> getCompletedCount() async {
    final challenges = await getCurrentDailyChallenges();
    return challenges.where((c) => c.isCompleted).length;
  }

  /// Get total challenges count for today
  static Future<int> getTotalCount() async {
    final challenges = await getCurrentDailyChallenges();
    return challenges.length;
  }

  /// Check if challenges are from today
  static Future<bool> areChallengesFromToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastChallengeDate = prefs.getString(_lastChallengeDateKey);
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return lastChallengeDate == todayString;
  }

  /// Get total rewards earned today
  static Future<int> getTotalRewardsEarned() async {
    final challenges = await getCurrentDailyChallenges();
    int totalRewards = 0;
    for (final challenge in challenges) {
      if (challenge.isCompleted) {
        totalRewards += challenge.rewardAmount ?? 0;
      }
    }
    return totalRewards;
  }
} 