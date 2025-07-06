# Modular Game Logic System

This document explains the new modular game logic system that allows for different game modes with separate logic implementations.

## Overview

The new system provides a clean separation of concerns by creating dedicated game logic classes for each game mode. This makes the code more maintainable, testable, and extensible.

## Architecture

### Base Interface
- `BaseGameLogic`: Abstract interface that all game logic implementations must follow
- `GameState`: Data class for tracking game progress
- `GameResult`: Data class for game results

### Game Logic Implementations

#### 1. AudioGameLogic
- **Purpose**: Handles music and sound guessing questions
- **Supported Types**: `sound`, `music`
- **Features**: 
  - Audio playback using AudioManager
  - Multiple choice answers
  - Different time limits for music vs sound
  - Visual audio player interface

#### 2. TrueFalseGameLogic
- **Purpose**: Handles true/false questions
- **Supported Types**: `truefalse`
- **Features**:
  - Simple true/false buttons
  - Text-based questions
  - Standard 15-second time limit
  - Clean, focused UI

#### 3. VocabularyGameLogic
- **Purpose**: Handles vocabulary and word-based questions
- **Supported Types**: `vocabulary`
- **Features**:
  - Multiple choice with lettered options (A, B, C, D)
  - Longer time limit (20 seconds) for reading
  - Text-based questions and answers
  - Professional quiz-style interface

### Factory and Management

#### GameLogicFactory
- **Purpose**: Creates and manages game logic instances
- **Features**:
  - Automatic game mode detection based on question types
  - Instance caching for performance
  - Game mode compatibility checking
  - Centralized initialization and disposal

#### GameManager
- **Purpose**: High-level game orchestration
- **Features**:
  - Question loading and management
  - Game state tracking
  - Integration with existing systems (stats, achievements, etc.)
  - Timer management
  - Result processing

## Usage Examples

### 1. Creating a New Game Mode

```dart
class MyCustomGameLogic extends BaseGameLogic {
  @override
  String get gameModeName => 'My Custom Game';
  
  @override
  String get gameModeDescription => 'Description of my custom game';
  
  @override
  IconData get gameModeIcon => Icons.star;
  
  @override
  bool supportsQuestionType(String type) {
    return type == 'mycustomtype';
  }
  
  @override
  Future<void> initialize() async {
    // Initialize any resources
  }
  
  @override
  Future<void> startQuestion(Question question) async {
    // Setup for the current question
  }
  
  @override
  Future<bool> handleAnswer(String? answer, Question question) async {
    // Handle user answer and return if correct
    return answer == question.correctAnswer;
  }
  
  @override
  Widget buildQuestionWidget(Question question, Function(String?) onAnswer) {
    // Build the UI for this question type
    return Container(
      child: Column(
        children: [
          // Your custom UI here
        ],
      ),
    );
  }
  
  @override
  int getTimeLimit(Question question) {
    return 15; // Custom time limit
  }
  
  @override
  void dispose() {
    // Clean up resources
  }
}
```

### 2. Using the Game Manager

```dart
final gameManager = GameManager();

// Initialize
await gameManager.initialize();

// Load questions with specific game mode
await gameManager.loadQuestions(
  difficulty: 'medium',
  category: 'animals',
  gameMode: 'audio', // or 'truefalse', 'vocabulary'
);

// Get the question widget
Widget questionWidget = gameManager.buildQuestionWidget();

// Handle answers
gameManager.handleAnswer('user_answer');

// Get results
GameResult? result = gameManager.getGameResult();
```

### 3. Game Selection Page

```dart
class GameSelectionPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final gameModes = GameLogicFactory.getAvailableGameModes();
    
    return ListView.builder(
      itemCount: gameModes.length,
      itemBuilder: (context, index) {
        final gameMode = gameModes[index];
        return GameModeCard(
          gameMode: gameMode,
          onTap: () => _startGame(gameMode.id),
        );
      },
    );
  }
}
```

## Question Data Structure

Questions should include a `type` field to determine which game logic to use:

```json
{
  "mode": "game",
  "category": "animals",
  "difficulty": "medium",
  "type": "sound", // or "music", "truefalse", "vocabulary"
  "file": "dog_bark.wav",
  "options": ["Dog", "Cat", "Bird", "Cow"],
  "correctAnswer": "Dog",
  "question": "What animal makes this sound?",
  "answer": null // for true/false questions
}
```

## Benefits

1. **Modularity**: Each game mode has its own logic and UI
2. **Maintainability**: Easy to modify one game mode without affecting others
3. **Extensibility**: Simple to add new game modes
4. **Testability**: Each game logic can be tested independently
5. **Performance**: Efficient resource management and caching
6. **User Experience**: Tailored UI for each game type

## Migration from Old System

The old monolithic game logic in `GamePage` can be gradually replaced:

1. Update `GamePage` to use `GameManager`
2. Convert existing questions to use the new type system
3. Add new game modes as needed
4. Remove old game logic code

## Future Enhancements

- Add more game modes (matching, sequencing, etc.)
- Implement adaptive difficulty
- Add multiplayer support
- Create game mode-specific achievements
- Add analytics for each game mode 