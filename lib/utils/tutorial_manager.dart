import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialManager {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _helpShownKey = 'help_shown';
  static const String _gameTutorialShownKey = 'game_tutorial_shown';
  static const String _settingsTutorialShownKey = 'settings_tutorial_shown';

  /// Check if main tutorial is completed
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Check if help has been shown
  static Future<bool> isHelpShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_helpShownKey) ?? false;
  }

  /// Mark help as shown
  static Future<void> markHelpShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_helpShownKey, true);
  }

  /// Check if game tutorial has been shown
  static Future<bool> isGameTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_gameTutorialShownKey) ?? false;
  }

  /// Mark game tutorial as shown
  static Future<void> markGameTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gameTutorialShownKey, true);
  }

  /// Check if settings tutorial has been shown
  static Future<bool> isSettingsTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_settingsTutorialShownKey) ?? false;
  }

  /// Mark settings tutorial as shown
  static Future<void> markSettingsTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_settingsTutorialShownKey, true);
  }

  /// Reset all tutorial states (for testing)
  static Future<void> resetTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_helpShownKey);
    await prefs.remove(_gameTutorialShownKey);
    await prefs.remove(_settingsTutorialShownKey);
  }

  /// Get tutorial content
  static Map<String, dynamic> getTutorialContent() {
    return {
      'welcome': {
        'title': 'Welcome to SoundSprint!',
        'description': 'Test your audio recognition skills with fun sound and music quizzes.',
        'steps': [
          'Listen to the audio clip carefully',
          'Choose the correct answer from 4 options',
          'Answer quickly to earn bonus points',
          'Track your progress and improve your skills'
        ]
      },
      'gameplay': {
        'title': 'How to Play',
        'description': 'Master the game mechanics to achieve high scores.',
        'steps': [
          'Sound questions: 10 seconds to answer',
          'Music questions: Up to 30 seconds to answer',
          'Correct answers earn points',
          'Quick answers earn bonus points',
          'Wrong answers or timeouts end the round'
        ]
      },
      'categories': {
        'title': 'Game Categories',
        'description': 'Explore different audio categories to challenge yourself.',
        'categories': [
          {'name': 'Animals', 'description': 'Animal sounds and calls'},
          {'name': 'Music', 'description': 'Musical instruments and genres'},
          {'name': 'Vehicles', 'description': 'Transportation sounds'},
          {'name': 'Nature', 'description': 'Natural environmental sounds'},
          {'name': 'Football', 'description': 'Sports and crowd sounds'},
          {'name': 'Science', 'description': 'Laboratory and scientific sounds'}
        ]
      },
      'difficulties': {
        'title': 'Difficulty Levels',
        'description': 'Choose the right challenge level for your skills.',
        'levels': [
          {'name': 'Easy', 'description': 'Simple, recognizable sounds'},
          {'name': 'Medium', 'description': 'Moderate complexity and variety'},
          {'name': 'Hard', 'description': 'Challenging and nuanced audio'}
        ]
      },
      'settings': {
        'title': 'Customize Your Experience',
        'description': 'Adjust settings to match your preferences.',
        'options': [
          'Volume control for audio playback',
          'Sound effects and music balance',
          'Visual theme preferences',
          'Accessibility options'
        ]
      }
    };
  }

  /// Get help content
  static Map<String, dynamic> getHelpContent() {
    return {
      'faq': [
        {
          'question': 'How do I start a game?',
          'answer': 'Tap the "Play" button on the home screen, then select your preferred category and difficulty level.'
        },
        {
          'question': 'What\'s the difference between sound and music questions?',
          'answer': 'Sound questions play short sound effects (3-5 seconds), while music questions play longer excerpts (10-30 seconds) from musical pieces.'
        },
        {
          'question': 'How is my score calculated?',
          'answer': 'You earn points for correct answers. Quick responses earn bonus points. Your accuracy and speed both contribute to your final score.'
        },
        {
          'question': 'Can I replay audio during a question?',
          'answer': 'Currently, each audio clip plays once per question. Focus carefully on the first play to maximize your chances of answering correctly.'
        },
        {
          'question': 'How do I improve my score?',
          'answer': 'Practice regularly, start with easier difficulties, and pay attention to audio patterns. Your skills will improve over time!'
        }
      ],
      'tips': [
        'Use headphones for better audio quality',
        'Start with Easy difficulty to learn the game',
        'Pay attention to audio patterns and characteristics',
        'Practice regularly to improve recognition skills',
        'Check your stats to track your progress'
      ],
      'troubleshooting': [
        {
          'issue': 'Audio not playing',
          'solution': 'Check your device volume, ensure audio is not muted in settings, and try restarting the app.'
        },
        {
          'issue': 'Game crashes or freezes',
          'solution': 'Close the app completely and restart it. If the problem persists, try clearing the app cache.'
        },
        {
          'issue': 'Missing audio files',
          'solution': 'Some audio files may be missing. The app will generate placeholder sounds for missing files.'
        }
      ]
    };
  }
} 