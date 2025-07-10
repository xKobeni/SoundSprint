import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/achievement.dart';
import 'package:flutter/material.dart';

class AchievementManager {
  static const String _achievementsKey = 'achievements';
  static const String _unlockedAchievementsKey = 'unlockedAchievements';

  // Predefined achievements
  static final List<Achievement> _defaultAchievements = [
    // First Steps & Beginner Achievements
    Achievement(
      id: 'first_game',
      title: 'First Steps',
      description: 'Complete your first game',
      icon: Icons.emoji_events,
      requirement: 1,
      type: 'games',
      maxProgress: 1,
    ),
    Achievement(
      id: 'first_perfect',
      title: 'Perfect Debut',
      description: 'Get a perfect score in your first game',
      icon: Icons.star,
      requirement: 1,
      type: 'score',
      maxProgress: 1,
    ),
    Achievement(
      id: 'first_streak',
      title: 'Getting Started',
      description: 'Win 2 games in a row',
      icon: Icons.local_fire_department,
      requirement: 2,
      type: 'streak',
      maxProgress: 2,
    ),

    // Score-based achievements
    Achievement(
      id: 'perfect_score',
      title: 'Perfect Score',
      description: 'Get a perfect score in any game',
      icon: Icons.star,
      requirement: 1,
      type: 'score',
      maxProgress: 1,
    ),
    Achievement(
      id: 'high_scorer',
      title: 'High Scorer',
      description: 'Score 80% or higher in 5 games',
      icon: Icons.emoji_events,
      requirement: 5,
      type: 'score',
      maxProgress: 5,
    ),
    Achievement(
      id: 'excellent_player',
      title: 'Excellent Player',
      description: 'Score 90% or higher in 10 games',
      icon: Icons.emoji_events,
      requirement: 10,
      type: 'score',
      maxProgress: 10,
    ),
    Achievement(
      id: 'master_player',
      title: 'Master Player',
      description: 'Score 95% or higher in 20 games',
      icon: Icons.diamond,
      requirement: 20,
      type: 'score',
      maxProgress: 20,
    ),
    
    // Streak-based achievements
    Achievement(
      id: 'streak_3',
      title: 'Getting Hot',
      description: 'Maintain a 3-game winning streak',
      icon: Icons.local_fire_department,
      requirement: 3,
      type: 'streak',
      maxProgress: 3,
    ),
    Achievement(
      id: 'streak_5',
      title: 'On Fire',
      description: 'Maintain a 5-game winning streak',
      icon: Icons.local_fire_department,
      requirement: 5,
      type: 'streak',
      maxProgress: 5,
    ),
    Achievement(
      id: 'streak_10',
      title: 'Unstoppable',
      description: 'Maintain a 10-game winning streak',
      icon: Icons.local_fire_department,
      requirement: 10,
      type: 'streak',
      maxProgress: 10,
    ),
    Achievement(
      id: 'streak_20',
      title: 'Legendary',
      description: 'Maintain a 20-game winning streak',
      icon: Icons.emoji_events,
      requirement: 20,
      type: 'streak',
      maxProgress: 20,
    ),
    
    // Game count achievements
    Achievement(
      id: 'games_10',
      title: 'Dedicated Player',
      description: 'Play 10 games',
      icon: Icons.videogame_asset,
      requirement: 10,
      type: 'games',
      maxProgress: 10,
    ),
    Achievement(
      id: 'games_25',
      title: 'Regular Player',
      description: 'Play 25 games',
      icon: Icons.videogame_asset,
      requirement: 25,
      type: 'games',
      maxProgress: 25,
    ),
    Achievement(
      id: 'games_50',
      title: 'Veteran Player',
      description: 'Play 50 games',
      icon: Icons.videogame_asset,
      requirement: 50,
      type: 'games',
      maxProgress: 50,
    ),
    Achievement(
      id: 'games_100',
      title: 'Century Club',
      description: 'Play 100 games',
      icon: Icons.emoji_events,
      requirement: 100,
      type: 'games',
      maxProgress: 100,
    ),
    Achievement(
      id: 'games_500',
      title: 'Addicted',
      description: 'Play 500 games',
      icon: Icons.diamond,
      requirement: 500,
      type: 'games',
      maxProgress: 500,
    ),
    
    // Accuracy achievements
    Achievement(
      id: 'accuracy_80',
      title: 'Good Listener',
      description: 'Achieve 80% accuracy in a game',
      icon: Icons.hearing,
      requirement: 1,
      type: 'accuracy',
      maxProgress: 1,
    ),
    Achievement(
      id: 'accuracy_90',
      title: 'Sharp Ears',
      description: 'Achieve 90% accuracy in a game',
      icon: Icons.hearing,
      requirement: 1,
      type: 'accuracy',
      maxProgress: 1,
    ),
    Achievement(
      id: 'accuracy_95',
      title: 'Golden Ears',
      description: 'Achieve 95% accuracy in a game',
      icon: Icons.hearing,
      requirement: 1,
      type: 'accuracy',
      maxProgress: 1,
    ),
    
    // Mode-specific achievements
    Achievement(
      id: 'sound_explorer',
      title: 'Sound Explorer',
      description: 'Complete 5 Guess the Sound games',
      icon: Icons.volume_up,
      requirement: 5,
      type: 'mode_sound',
      maxProgress: 5,
    ),
    Achievement(
      id: 'sound_master',
      title: 'Sound Master',
      description: 'Complete 20 Guess the Sound games',
      icon: Icons.volume_up,
      requirement: 20,
      type: 'mode_sound',
      maxProgress: 20,
    ),
    Achievement(
      id: 'music_explorer',
      title: 'Music Explorer',
      description: 'Complete 5 Guess the Music games',
      icon: Icons.music_note,
      requirement: 5,
      type: 'mode_music',
      maxProgress: 5,
    ),
    Achievement(
      id: 'music_master',
      title: 'Music Master',
      description: 'Complete 20 Guess the Music games',
      icon: Icons.music_note,
      requirement: 20,
      type: 'mode_music',
      maxProgress: 20,
    ),
    Achievement(
      id: 'truth_seeker',
      title: 'Truth Seeker',
      description: 'Complete 5 True or False games',
      icon: Icons.check_circle,
      requirement: 5,
      type: 'mode_truefalse',
      maxProgress: 5,
    ),
    Achievement(
      id: 'truth_master',
      title: 'Truth Master',
      description: 'Complete 20 True or False games',
      icon: Icons.check_circle,
      requirement: 20,
      type: 'mode_truefalse',
      maxProgress: 20,
    ),
    Achievement(
      id: 'word_wizard',
      title: 'Word Wizard',
      description: 'Complete 5 Vocabulary games',
      icon: Icons.book,
      requirement: 5,
      type: 'mode_vocabulary',
      maxProgress: 5,
    ),
    Achievement(
      id: 'word_master',
      title: 'Word Master',
      description: 'Complete 20 Vocabulary games',
      icon: Icons.book,
      requirement: 20,
      type: 'mode_vocabulary',
      maxProgress: 20,
    ),

    // Category-specific achievements
    Achievement(
      id: 'meme_lord',
      title: 'Meme Lord',
      description: 'Complete 10 Filipino Memes Sound games',
      icon: Icons.sentiment_very_satisfied,
      requirement: 10,
      type: 'category_filipino_memes',
      maxProgress: 10,
    ),
    Achievement(
      id: 'popular_culture',
      title: 'Popular Culture',
      description: 'Complete 10 Popular Memes Sound games',
      icon: Icons.public,
      requirement: 10,
      type: 'category_popular_memes',
      maxProgress: 10,
    ),
    Achievement(
      id: 'animal_whisperer',
      title: 'Animal Whisperer',
      description: 'Complete 10 Animal Sound games',
      icon: Icons.pets,
      requirement: 10,
      type: 'category_animal',
      maxProgress: 10,
    ),
    Achievement(
      id: 'nature_lover',
      title: 'Nature Lover',
      description: 'Complete 10 Nature Sound games',
      icon: Icons.nature,
      requirement: 10,
      type: 'category_nature',
      maxProgress: 10,
    ),
    Achievement(
      id: 'kpop_fan',
      title: 'K-pop Fan',
      description: 'Complete 10 Kpop Music games',
      icon: Icons.flag,
      requirement: 10,
      type: 'category_kpop',
      maxProgress: 10,
    ),
    Achievement(
      id: 'anime_otaku',
      title: 'Anime Otaku',
      description: 'Complete 10 Anime Openings games',
      icon: Icons.flag,
      requirement: 10,
      type: 'category_anime',
      maxProgress: 10,
    ),
    Achievement(
      id: 'opm_lover',
      title: 'OPM Lover',
      description: 'Complete 10 OPM Musics games',
      icon: Icons.flag,
      requirement: 10,
      type: 'category_opm',
      maxProgress: 10,
    ),
    Achievement(
      id: 'knowledge_seeker',
      title: 'Knowledge Seeker',
      description: 'Complete 10 General Knowledge games',
      icon: Icons.lightbulb,
      requirement: 10,
      type: 'category_general_knowledge',
      maxProgress: 10,
    ),
    Achievement(
      id: 'science_geek',
      title: 'Science Geek',
      description: 'Complete 10 Science Facts games',
      icon: Icons.science,
      requirement: 10,
      type: 'category_science',
      maxProgress: 10,
    ),
    Achievement(
      id: 'synonym_hunter',
      title: 'Synonym Hunter',
      description: 'Complete 10 English Synonyms games',
      icon: Icons.translate,
      requirement: 10,
      type: 'category_english_synonyms',
      maxProgress: 10,
    ),
    Achievement(
      id: 'translation_expert',
      title: 'Translation Expert',
      description: 'Complete 10 Filipino-English Translation games',
      icon: Icons.public,
      requirement: 10,
      type: 'category_filipino_english',
      maxProgress: 10,
    ),
    
    // Difficulty achievements
    Achievement(
      id: 'easy_complete',
      title: 'Easy Does It',
      description: 'Complete 10 easy difficulty games',
      icon: Icons.sentiment_very_satisfied,
      requirement: 10,
      type: 'difficulty_easy',
      maxProgress: 10,
    ),
    Achievement(
      id: 'medium_complete',
      title: 'Middle Ground',
      description: 'Complete 10 medium difficulty games',
      icon: Icons.sentiment_neutral,
      requirement: 10,
      type: 'difficulty_medium',
      maxProgress: 10,
    ),
    Achievement(
      id: 'hard_complete',
      title: 'Hard Core',
      description: 'Complete 10 hard difficulty games',
      icon: Icons.sentiment_very_dissatisfied,
      requirement: 10,
      type: 'difficulty_hard',
      maxProgress: 10,
    ),
    Achievement(
      id: 'hard_master',
      title: 'Hard Master',
      description: 'Complete 50 hard difficulty games',
      icon: Icons.sentiment_very_dissatisfied,
      requirement: 50,
      type: 'difficulty_hard',
      maxProgress: 50,
    ),

    // Speed achievements
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete a game in under 30 seconds',
      icon: Icons.speed,
      requirement: 1,
      type: 'speed',
      maxProgress: 1,
    ),
    Achievement(
      id: 'lightning_fast',
      title: 'Lightning Fast',
      description: 'Complete 5 games in under 30 seconds each',
      icon: Icons.speed,
      requirement: 5,
      type: 'speed',
      maxProgress: 5,
    ),

    // Variety achievements
    Achievement(
      id: 'mode_explorer',
      title: 'Mode Explorer',
      description: 'Play all 4 game modes',
      icon: Icons.games,
      requirement: 4,
      type: 'variety_modes',
      maxProgress: 4,
    ),
    Achievement(
      id: 'category_explorer',
      title: 'Category Explorer',
      description: 'Play 10 different categories',
      icon: Icons.category,
      requirement: 10,
      type: 'variety_categories',
      maxProgress: 10,
    ),
    Achievement(
      id: 'difficulty_explorer',
      title: 'Difficulty Explorer',
      description: 'Play all 3 difficulty levels',
      icon: Icons.sort,
      requirement: 3,
      type: 'variety_difficulties',
      maxProgress: 3,
    ),

    // Special achievements
    Achievement(
      id: 'daily_player',
      title: 'Daily Player',
      description: 'Play games on 7 consecutive days',
      icon: Icons.calendar_today,
      requirement: 7,
      type: 'daily_streak',
      maxProgress: 7,
    ),
    Achievement(
      id: 'weekend_warrior',
      title: 'Weekend Warrior',
      description: 'Play games on 4 consecutive weekends',
      icon: Icons.sports_football,
      requirement: 4,
      type: 'weekend_streak',
      maxProgress: 4,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Play 10 games between 10 PM and 6 AM',
      icon: Icons.nightlight_round,
      requirement: 10,
      type: 'night_games',
      maxProgress: 10,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Play 10 games between 6 AM and 10 AM',
      icon: Icons.flight_takeoff,
      requirement: 10,
      type: 'morning_games',
      maxProgress: 10,
    ),

    // Milestone achievements
    Achievement(
      id: 'first_100',
      title: 'First Hundred',
      description: 'Score 100 total points',
      icon: Icons.emoji_events,
      requirement: 100,
      type: 'total_score',
      maxProgress: 100,
    ),
    Achievement(
      id: 'score_500',
      title: 'Half Thousand',
      description: 'Score 500 total points',
      icon: Icons.emoji_events,
      requirement: 500,
      type: 'total_score',
      maxProgress: 500,
    ),
    Achievement(
      id: 'score_1000',
      title: 'Thousand Club',
      description: 'Score 1000 total points',
      icon: Icons.emoji_events,
      requirement: 1000,
      type: 'total_score',
      maxProgress: 1000,
    ),
    Achievement(
      id: 'score_5000',
      title: 'Five Thousand',
      description: 'Score 5000 total points',
      icon: Icons.emoji_events,
      requirement: 5000,
      type: 'total_score',
      maxProgress: 5000,
    ),
  ];

  /// Initialize achievements for new users
  static Future<void> initializeAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAchievements = prefs.containsKey(_achievementsKey);
    
    if (!hasAchievements) {
      final achievementsJson = _defaultAchievements.map((a) => a.toJson()).toList();
      await prefs.setString(_achievementsKey, json.encode(achievementsJson));
    }
  }

  /// Get all achievements
  static Future<List<Achievement>> getAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey) ?? '[]';
    
    try {
      final List<dynamic> achievementsList = json.decode(achievementsJson);
      return achievementsList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      return _defaultAchievements;
    }
  }

  /// Update achievement progress based on game results
  static Future<List<Achievement>> updateProgress({
    required int score,
    required int totalQuestions,
    required String category,
    required String difficulty,
    required int currentStreak,
    String? mode,
    int? playtimeSeconds,
    DateTime? gameStartTime,
  }) async {
    final achievements = await getAllAchievements();
    final updatedAchievements = <Achievement>[];
    final newlyUnlocked = <Achievement>[];
    
    // Get current stats for milestone achievements
    final stats = await _getCurrentStats();
    final totalScore = stats['totalScore'] ?? 0;
    final totalGames = stats['totalGames'] ?? 0;
    final playedModes = stats['playedModes'] ?? <String>{};
    final playedCategories = stats['playedCategories'] ?? <String>{};
    final playedDifficulties = stats['playedDifficulties'] ?? <String>{};
    final dailyStreak = stats['dailyStreak'] ?? 0;
    final weekendStreak = stats['weekendStreak'] ?? 0;
    final nightGames = stats['nightGames'] ?? 0;
    final morningGames = stats['morningGames'] ?? 0;
    final speedGames = stats['speedGames'] ?? 0;
    
    // Update tracking data
    await _updateTrackingData(
      mode: mode,
      category: category,
      difficulty: difficulty,
      playtimeSeconds: playtimeSeconds,
      gameStartTime: gameStartTime,
      gameScore: score,
    );
    
    for (final achievement in achievements) {
      if (achievement.isUnlocked) {
        updatedAchievements.add(achievement);
        continue;
      }
      
      int newProgress = achievement.progress;
      bool shouldUnlock = false;
      
      switch (achievement.type) {
        case 'score':
          if (achievement.id == 'perfect_score' && score == totalQuestions) {
            newProgress = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'first_perfect' && score == totalQuestions && totalGames == 0) {
            newProgress = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'high_scorer' && score >= (totalQuestions * 0.8)) {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          } else if (achievement.id == 'excellent_player' && score >= (totalQuestions * 0.9)) {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          } else if (achievement.id == 'master_player' && score >= (totalQuestions * 0.95)) {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        case 'streak':
          if (achievement.id == 'first_streak' && currentStreak >= 2) {
            newProgress = 2;
            shouldUnlock = true;
          } else if (currentStreak >= achievement.requirement) {
            newProgress = achievement.requirement;
            shouldUnlock = true;
          }
          break;
          
        case 'games':
          if (achievement.id == 'first_game' && totalGames == 0) {
            newProgress = 1;
            shouldUnlock = true;
          } else {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        case 'accuracy':
          final accuracy = score / totalQuestions;
          if (achievement.id == 'accuracy_80' && accuracy >= 0.8) {
            newProgress = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'accuracy_90' && accuracy >= 0.9) {
            newProgress = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'accuracy_95' && accuracy >= 0.95) {
            newProgress = 1;
            shouldUnlock = true;
          }
          break;
          
        // Mode-specific achievements
        case 'mode_sound':
          if (mode == 'GuessTheSound') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'mode_music':
          if (mode == 'GuessTheMusic') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'mode_truefalse':
          if (mode == 'TrueOrFalse') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'mode_vocabulary':
          if (mode == 'Vocabulary') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        // Category-specific achievements
        case 'category_filipino_memes':
          if (category == 'Filipino Memes Sound') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_popular_memes':
          if (category == 'Popular Memes Sound') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_animal':
          if (category == 'Animal Sound') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_nature':
          if (category == 'Nature Sound') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_kpop':
          if (category == 'Kpop Music') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_anime':
          if (category == 'Anime Openings') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_opm':
          if (category == 'OPM Musics') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_general_knowledge':
          if (category == 'General Knowledge') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_science':
          if (category == 'Science Facts') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_english_synonyms':
          if (category == 'English Synonyms') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'category_filipino_english':
          if (category == 'Filipino-English Translation') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        // Difficulty achievements
        case 'difficulty_easy':
          if (difficulty == 'Easy') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'difficulty_medium':
          if (difficulty == 'Medium') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
        case 'difficulty_hard':
          if (difficulty == 'Hard') {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        // Speed achievements
        case 'speed':
          if (playtimeSeconds != null && playtimeSeconds <= 30) {
            newProgress = achievement.progress + 1;
            shouldUnlock = newProgress >= achievement.requirement;
          }
          break;
          
        // Variety achievements
        case 'variety_modes':
          final updatedModes = {...playedModes, mode ?? ''};
          newProgress = updatedModes.length;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
        case 'variety_categories':
          final updatedCategories = {...playedCategories, category};
          newProgress = updatedCategories.length;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
        case 'variety_difficulties':
          final updatedDifficulties = {...playedDifficulties, difficulty};
          newProgress = updatedDifficulties.length;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
          
        // Special time-based achievements
        case 'daily_streak':
          newProgress = dailyStreak;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
        case 'weekend_streak':
          newProgress = weekendStreak;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
        case 'night_games':
          if (gameStartTime != null) {
            final hour = gameStartTime.hour;
            if (hour >= 22 || hour <= 6) {
              newProgress = achievement.progress + 1;
              shouldUnlock = newProgress >= achievement.requirement;
            }
          }
          break;
        case 'morning_games':
          if (gameStartTime != null) {
            final hour = gameStartTime.hour;
            if (hour >= 6 && hour <= 10) {
              newProgress = achievement.progress + 1;
              shouldUnlock = newProgress >= achievement.requirement;
            }
          }
          break;
          
        // Milestone achievements
        case 'total_score':
          final newTotalScore = totalScore + score;
          newProgress = newTotalScore;
          shouldUnlock = newProgress >= achievement.requirement;
          break;
      }
      
      final updatedAchievement = achievement.copyWith(
        progress: newProgress,
        isUnlocked: shouldUnlock,
        unlockedAt: shouldUnlock ? DateTime.now() : null,
      );
      
      updatedAchievements.add(updatedAchievement);
      
      if (shouldUnlock) {
        newlyUnlocked.add(updatedAchievement);
      }
    }
    
    // Save updated achievements
    await _saveAchievements(updatedAchievements);
    
    return newlyUnlocked;
  }

  /// Get current stats for milestone achievements
  static Future<Map<String, dynamic>> _getCurrentStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalScore': prefs.getInt('totalScore') ?? 0,
      'totalGames': prefs.getInt('totalGames') ?? 0,
      'playedModes': prefs.getStringList('playedModes')?.toSet() ?? <String>{},
      'playedCategories': prefs.getStringList('playedCategories')?.toSet() ?? <String>{},
      'playedDifficulties': prefs.getStringList('playedDifficulties')?.toSet() ?? <String>{},
      'dailyStreak': prefs.getInt('dailyStreak') ?? 0,
      'weekendStreak': prefs.getInt('weekendStreak') ?? 0,
      'nightGames': prefs.getInt('nightGames') ?? 0,
      'morningGames': prefs.getInt('morningGames') ?? 0,
      'speedGames': prefs.getInt('speedGames') ?? 0,
    };
  }

  /// Update tracking data for achievements
  static Future<void> _updateTrackingData({
    String? mode,
    String? category,
    String? difficulty,
    int? playtimeSeconds,
    DateTime? gameStartTime,
    int? gameScore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update total score and games
    final currentScore = prefs.getInt('totalScore') ?? 0;
    final currentGames = prefs.getInt('totalGames') ?? 0;
    await prefs.setInt('totalScore', currentScore + (gameScore ?? 0));
    await prefs.setInt('totalGames', currentGames + 1);
    
    // Update played modes
    if (mode != null) {
      final playedModes = prefs.getStringList('playedModes') ?? [];
      if (!playedModes.contains(mode)) {
        playedModes.add(mode);
        await prefs.setStringList('playedModes', playedModes);
      }
    }
    
    // Update played categories
    if (category != null) {
      final playedCategories = prefs.getStringList('playedCategories') ?? [];
      if (!playedCategories.contains(category)) {
        playedCategories.add(category);
        await prefs.setStringList('playedCategories', playedCategories);
      }
    }
    
    // Update played difficulties
    if (difficulty != null) {
      final playedDifficulties = prefs.getStringList('playedDifficulties') ?? [];
      if (!playedDifficulties.contains(difficulty)) {
        playedDifficulties.add(difficulty);
        await prefs.setStringList('playedDifficulties', playedDifficulties);
      }
    }
    
    // Update speed games
    if (playtimeSeconds != null && playtimeSeconds <= 30) {
      final speedGames = prefs.getInt('speedGames') ?? 0;
      await prefs.setInt('speedGames', speedGames + 1);
    }
    
    // Update time-based tracking
    if (gameStartTime != null) {
      final hour = gameStartTime.hour;
      if (hour >= 22 || hour <= 6) {
        final nightGames = prefs.getInt('nightGames') ?? 0;
        await prefs.setInt('nightGames', nightGames + 1);
      } else if (hour >= 6 && hour <= 10) {
        final morningGames = prefs.getInt('morningGames') ?? 0;
        await prefs.setInt('morningGames', morningGames + 1);
      }
    }
  }

  /// Save achievements to storage
  static Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = achievements.map((a) => a.toJson()).toList();
    await prefs.setString(_achievementsKey, json.encode(achievementsJson));
  }

  /// Get unlocked achievements count
  static Future<int> getUnlockedCount() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.isUnlocked).length;
  }

  /// Get total achievements count
  static Future<int> getTotalCount() async {
    final achievements = await getAllAchievements();
    return achievements.length;
  }

  /// Get achievement by ID
  static Future<Achievement?> getAchievementById(String id) async {
    final achievements = await getAllAchievements();
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Reset all achievements (for testing purposes)
  static Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    await prefs.remove('totalScore');
    await prefs.remove('totalGames');
    await prefs.remove('playedModes');
    await prefs.remove('playedCategories');
    await prefs.remove('playedDifficulties');
    await prefs.remove('dailyStreak');
    await prefs.remove('weekendStreak');
    await prefs.remove('nightGames');
    await prefs.remove('morningGames');
    await prefs.remove('speedGames');
    
    // Re-initialize achievements
    await initializeAchievements();
  }

  /// Get current tracking stats (for debugging)
  static Future<Map<String, dynamic>> getCurrentStats() async {
    return await _getCurrentStats();
  }
} 