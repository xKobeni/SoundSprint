import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityManager {
  static final AccessibilityManager _instance = AccessibilityManager._internal();
  factory AccessibilityManager() => _instance;
  AccessibilityManager._internal();

  // Settings
  bool _hapticFeedbackEnabled = true;
  bool _visualIndicatorsEnabled = true;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  double _animationSpeed = 1.0;

  /// Initialize accessibility settings
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// Load accessibility settings from preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticFeedbackEnabled = prefs.getBool('haptic_feedback_enabled') ?? true;
      _visualIndicatorsEnabled = prefs.getBool('visual_indicators_enabled') ?? true;
      _highContrastEnabled = prefs.getBool('high_contrast_enabled') ?? false;
      _largeTextEnabled = prefs.getBool('large_text_enabled') ?? false;
      _animationSpeed = prefs.getDouble('animation_speed') ?? 1.0;
    } catch (e) {
      print('Error loading accessibility settings: $e');
    }
  }

  /// Save accessibility settings
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('haptic_feedback_enabled', _hapticFeedbackEnabled);
      await prefs.setBool('visual_indicators_enabled', _visualIndicatorsEnabled);
      await prefs.setBool('high_contrast_enabled', _highContrastEnabled);
      await prefs.setBool('large_text_enabled', _largeTextEnabled);
      await prefs.setDouble('animation_speed', _animationSpeed);
    } catch (e) {
      print('Error saving accessibility settings: $e');
    }
  }

  /// Trigger haptic feedback
  Future<void> triggerHapticFeedback(HapticFeedbackType type) async {
    if (!_hapticFeedbackEnabled) return;

    try {
      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.vibrate:
          await HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      print('Error triggering haptic feedback: $e');
    }
  }

  /// Get visual indicator for audio state
  Widget getAudioVisualIndicator({
    required bool isPlaying,
    required bool isMuted,
    required double volume,
    double size = 24.0,
  }) {
    if (!_visualIndicatorsEnabled) return const SizedBox.shrink();

    IconData icon;
    Color color;

    if (isMuted) {
      icon = Icons.volume_off;
      color = Colors.red;
    } else if (isPlaying) {
      icon = Icons.volume_up;
      color = volume > 0.5 ? Colors.green : Colors.orange;
    } else {
      icon = Icons.volume_down;
      color = Colors.grey;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: (300 * _animationSpeed).round()),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  /// Get visual indicator for timer
  Widget getTimerVisualIndicator({
    required int currentTime,
    required int maxTime,
    double size = 24.0,
  }) {
    if (!_visualIndicatorsEnabled) return const SizedBox.shrink();

    final progress = currentTime / maxTime;
    Color color;

    if (progress > 0.6) {
      color = Colors.green;
    } else if (progress > 0.3) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: (200 * _animationSpeed).round()),
      child: Icon(
        Icons.timer,
        color: color,
        size: size,
      ),
    );
  }

  /// Get visual indicator for answer state
  Widget getAnswerVisualIndicator({
    required AnswerState state,
    double size = 24.0,
  }) {
    if (!_visualIndicatorsEnabled) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (state) {
      case AnswerState.correct:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AnswerState.incorrect:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case AnswerState.timeout:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case AnswerState.neutral:
        icon = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: (300 * _animationSpeed).round()),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  /// Get accessibility text for audio state
  String getAudioAccessibilityText({
    required bool isPlaying,
    required bool isMuted,
    required double volume,
  }) {
    if (isMuted) {
      return 'Audio is muted';
    } else if (isPlaying) {
      return 'Audio is playing at ${(volume * 100).round()}% volume';
    } else {
      return 'Audio is paused';
    }
  }

  /// Get accessibility text for timer
  String getTimerAccessibilityText({
    required int currentTime,
    required int maxTime,
  }) {
    final remaining = maxTime - currentTime;
    if (remaining <= 0) {
      return 'Time is up';
    } else if (remaining <= 3) {
      return 'Warning: Only $remaining seconds remaining';
    } else {
      return '$remaining seconds remaining';
    }
  }

  /// Get accessibility text for answer
  String getAnswerAccessibilityText({
    required AnswerState state,
    String? userAnswer,
    String? correctAnswer,
  }) {
    switch (state) {
      case AnswerState.correct:
        return 'Correct! Well done!';
      case AnswerState.incorrect:
        return 'Incorrect. The correct answer was $correctAnswer';
      case AnswerState.timeout:
        return 'Time ran out. The correct answer was $correctAnswer';
      case AnswerState.neutral:
        return 'Please select an answer';
    }
  }

  /// Get high contrast theme
  ThemeData getHighContrastTheme(ThemeData baseTheme) {
    if (!_highContrastEnabled) return baseTheme;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: Colors.white,
        secondary: Colors.yellow,
        surface: Colors.black,
        background: Colors.black,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  /// Get large text theme
  ThemeData getLargeTextTheme(ThemeData baseTheme) {
    if (!_largeTextEnabled) return baseTheme;

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: 1.3,
      ),
    );
  }

  /// Get animation duration based on accessibility settings
  Duration getAnimationDuration(Duration baseDuration) {
    return Duration(milliseconds: (baseDuration.inMilliseconds * _animationSpeed).round());
  }

  // Getters and setters
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get visualIndicatorsEnabled => _visualIndicatorsEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  double get animationSpeed => _animationSpeed;

  set hapticFeedbackEnabled(bool value) {
    _hapticFeedbackEnabled = value;
    saveSettings();
  }

  set visualIndicatorsEnabled(bool value) {
    _visualIndicatorsEnabled = value;
    saveSettings();
  }

  set highContrastEnabled(bool value) {
    _highContrastEnabled = value;
    saveSettings();
  }

  set largeTextEnabled(bool value) {
    _largeTextEnabled = value;
    saveSettings();
  }

  set animationSpeed(double value) {
    _animationSpeed = value.clamp(0.5, 2.0);
    saveSettings();
  }
}

/// Haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// Answer states for visual indicators
enum AnswerState {
  correct,
  incorrect,
  timeout,
  neutral,
} 