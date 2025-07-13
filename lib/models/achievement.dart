import 'package:flutter/material.dart';

// Expanded icon map for diverse achievement icons
const Map<String, IconData> achievementIconMap = {
  'trophy': Icons.emoji_events,
  'star': Icons.star,
  'fire': Icons.local_fire_department,
  'medal': Icons.military_tech,
  'game': Icons.videogame_asset,
  'hearing': Icons.hearing,
  'volume_up': Icons.volume_up,
  'music_note': Icons.music_note,
  'check_circle': Icons.check_circle,
  'book': Icons.book,
  'meme': Icons.sentiment_very_satisfied,
  'pets': Icons.pets,
  'nature': Icons.nature,
  'audiotrack': Icons.audiotrack,
  'flag': Icons.flag,
  'lightbulb': Icons.lightbulb,
  'science': Icons.science,
  'translate': Icons.translate,
  'easy': Icons.sentiment_very_satisfied,
  'medium': Icons.sentiment_neutral,
  'hard': Icons.sentiment_very_dissatisfied,
  'speed': Icons.speed,
  'category': Icons.category,
  'games': Icons.games,
  'sort': Icons.sort,
  'calendar': Icons.calendar_today,
  'football': Icons.sports_football,
  'night': Icons.nightlight_round,
  'morning': Icons.flight_takeoff,
  'public': Icons.public,
  'sentiment_very_satisfied': Icons.sentiment_very_satisfied,
  'sentiment_neutral': Icons.sentiment_neutral,
  'sentiment_very_dissatisfied': Icons.sentiment_very_dissatisfied,
  'sports_football': Icons.sports_football,
  'nightlight_round': Icons.nightlight_round,
  'flight_takeoff': Icons.flight_takeoff,
  'calendar_today': Icons.calendar_today,
  'diamond': Icons.diamond,
  'military_tech': Icons.military_tech,
  'lightbulb_outline': Icons.lightbulb_outline,
  // Add more as needed
};

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String iconName; // New: store the icon name
  final int requirement;
  final String type; // 'score', 'streak', 'games', 'accuracy', 'category', 'difficulty'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconName, // New
    required this.requirement,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.maxProgress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final iconName = json['iconName'] as String? ?? 'star';
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: achievementIconMap[iconName] ?? Icons.help_outline,
      iconName: iconName,
      requirement: json['requirement'] as int,
      type: json['type'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
      progress: json['progress'] as int? ?? 0,
      maxProgress: json['maxProgress'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName, // Store icon name
      'requirement': requirement,
      'type': type,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'maxProgress': maxProgress,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    String? iconName,
    int? requirement,
    String? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      requirement: requirement ?? this.requirement,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
} 