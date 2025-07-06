import 'package:flutter/material.dart';
import 'base_game_logic.dart';
import 'audio_game_logic.dart';
import 'true_false_game_logic.dart';
import 'vocabulary_game_logic.dart';

/// Factory class to create and manage game logic instances
class GameLogicFactory {
  static final Map<String, BaseGameLogic> _instances = {};
  static final Map<String, BaseGameLogic> _gameModes = {
    'GuessTheSound': AudioGameLogic(type: 'sound'),
    'GuessTheMusic': AudioGameLogic(type: 'music'),
    'TrueOrFalse': TrueFalseGameLogic(),
    'Vocabulary': VocabularyGameLogic(),
  };

  /// Get the appropriate game logic for a question type
  static BaseGameLogic getGameLogicForQuestionType(String questionType) {
    // Check if we already have an instance for this type
    if (_instances.containsKey(questionType)) {
      return _instances[questionType]!;
    }

    // Find the appropriate game logic
    BaseGameLogic? gameLogic;
    for (final logic in _gameModes.values) {
      if (logic.supportsQuestionType(questionType)) {
        gameLogic = logic;
        break;
      }
    }

    if (gameLogic == null) {
      throw ArgumentError('No game logic found for question type: $questionType');
    }

    // Store the instance for reuse
    _instances[questionType] = gameLogic;
    return gameLogic;
  }

  /// Get all available game modes
  static List<GameModeInfo> getAvailableGameModes() {
    return _gameModes.entries.map((entry) {
      final logic = entry.value;
      return GameModeInfo(
        id: entry.key,
        name: logic.gameModeName,
        description: logic.gameModeDescription,
        icon: logic.gameModeIcon,
        supportedTypes: _getSupportedTypes(logic),
      );
    }).toList();
  }

  /// Get supported question types for a specific game logic
  static List<String> _getSupportedTypes(BaseGameLogic logic) {
    final supportedTypes = <String>[];
    if (logic.supportsQuestionType('sound')) supportedTypes.add('sound');
    if (logic.supportsQuestionType('music')) supportedTypes.add('music');
    if (logic.supportsQuestionType('truefalse')) supportedTypes.add('truefalse');
    if (logic.supportsQuestionType('vocabulary')) supportedTypes.add('vocabulary');
    return supportedTypes;
  }

  /// Get game logic by game mode ID
  static BaseGameLogic getGameLogicByModeId(String modeId) {
    final gameLogic = _gameModes[modeId];
    if (gameLogic == null) {
      throw ArgumentError('Unknown game mode: $modeId');
    }
    return gameLogic;
  }

  /// Initialize all game logic instances
  static Future<void> initializeAll() async {
    for (final logic in _gameModes.values) {
      await logic.initialize();
    }
  }

  /// Dispose all game logic instances
  static void disposeAll() {
    for (final logic in _gameModes.values) {
      logic.dispose();
    }
    _instances.clear();
  }

  /// Check if a question type is supported by any game logic
  static bool isQuestionTypeSupported(String questionType) {
    return _gameModes.values.any((logic) => logic.supportsQuestionType(questionType));
  }

  /// Check if a game mode exists
  static bool isGameModeSupported(String gameMode) {
    return _gameModes.keys.contains(gameMode);
  }

  /// Get the game mode name for a question type
  static String getGameModeNameForQuestionType(String questionType) {
    for (final logic in _gameModes.values) {
      if (logic.supportsQuestionType(questionType)) {
        return logic.gameModeName;
      }
    }
    return 'Unknown';
  }
}

/// Information about a game mode
class GameModeInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> supportedTypes;

  const GameModeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.supportedTypes,
  });
}

/// Game mode selection helper
class GameModeSelector {
  /// Get the best game mode for a list of questions
  static String selectGameModeForQuestions(List<dynamic> questions) {
    if (questions.isEmpty) return 'GuessTheSound'; // Default

    // Count question types and modes
    final typeCounts = <String, int>{};
    final modeCounts = <String, int>{};
    
    for (final question in questions) {
      final type = question['type'] as String? ?? 'sound';
      final mode = question['mode'] as String? ?? 'GuessTheSound';
      
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      modeCounts[mode] = (modeCounts[mode] ?? 0) + 1;
    }

    // Find the most common mode first
    String? mostCommonMode;
    int maxModeCount = 0;
    for (final entry in modeCounts.entries) {
      if (entry.value > maxModeCount) {
        maxModeCount = entry.value;
        mostCommonMode = entry.key;
      }
    }

    // Return the appropriate game mode based on mode
    if (mostCommonMode != null && GameLogicFactory.isGameModeSupported(mostCommonMode)) {
      return mostCommonMode;
    }

    // Fallback to type-based selection
    String? mostCommonType;
    int maxTypeCount = 0;
    for (final entry in typeCounts.entries) {
      if (entry.value > maxTypeCount) {
        maxTypeCount = entry.value;
        mostCommonType = entry.key;
      }
    }

    // Return the appropriate game mode based on type
    if (mostCommonType == 'truefalse') return 'TrueOrFalse';
    if (mostCommonType == 'vocabulary') return 'Vocabulary';
    return 'GuessTheSound'; // Default for sound/music
  }

  /// Check if questions are compatible with a specific game mode
  static bool areQuestionsCompatibleWithMode(List<dynamic> questions, String modeId) {
    final gameLogic = GameLogicFactory.getGameLogicByModeId(modeId);
    
    for (final question in questions) {
      final type = question['type'] as String? ?? 'sound';
      if (!gameLogic.supportsQuestionType(type)) {
        return false;
      }
    }
    return true;
  }
} 