import 'package:flutter_test/flutter_test.dart';
import '../managers/game_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameManager Disposal Tests', () {
    test('should not throw when disposed and timer is running', () async {
      final gameManager = GameManager();
      
      // Initialize the manager
      await gameManager.initialize();
      
      // Load some questions to start the timer
      await gameManager.loadQuestions(
        gameMode: 'GuessTheSound',
        difficulty: 'Easy',
        category: 'Animal Sound',
      );
      
      // Wait a moment for timer to start
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Dispose the manager while timer is running
      gameManager.dispose();
      
      // Wait a bit more to see if any errors occur
      await Future.delayed(const Duration(milliseconds: 200));
      
      // If we get here without errors, the disposal fix worked
      expect(true, true);
    });

    test('should not call setState after disposal', () async {
      final gameManager = GameManager();
      
      // Initialize the manager
      await gameManager.initialize();
      
      // Dispose immediately
      gameManager.dispose();
      
      // Try to call setState - should not throw
      expect(() => gameManager.setState(() {}), returnsNormally);
      
      // Check that mounted returns false
      expect(gameManager.mounted, false);
    });

    test('should not call handleAnswer after disposal', () async {
      final gameManager = GameManager();
      
      // Initialize the manager
      await gameManager.initialize();
      
      // Load some questions
      await gameManager.loadQuestions(
        gameMode: 'GuessTheSound',
        difficulty: 'Easy',
        category: 'Animal Sound',
      );
      
      // Dispose the manager
      gameManager.dispose();
      
      // Try to handle an answer - should not throw
      expect(() => gameManager.handleAnswer('test'), returnsNormally);
    });

    test('should not call loadQuestions after disposal', () async {
      final gameManager = GameManager();
      
      // Initialize the manager
      await gameManager.initialize();
      
      // Dispose the manager
      gameManager.dispose();
      
      // Try to load questions - should not throw
      expect(() => gameManager.loadQuestions(gameMode: 'GuessTheSound'), returnsNormally);
    });

    test('should return empty list for getAvailableGameModes after disposal', () {
      final gameManager = GameManager();
      
      // Dispose the manager
      gameManager.dispose();
      
      // Should return empty list
      expect(gameManager.getAvailableGameModes(), isEmpty);
    });

    test('should return null for getGameResult after disposal', () {
      final gameManager = GameManager();
      
      // Dispose the manager
      gameManager.dispose();
      
      // Should return null
      expect(gameManager.getGameResult(), isNull);
    });
  });
} 