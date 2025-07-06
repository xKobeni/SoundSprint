import 'package:flutter_test/flutter_test.dart';
import 'game_logic/game_logic_factory.dart';
import 'game_logic/base_game_logic.dart';

void main() {
  group('Game Logic Factory Tests', () {
    test('should return correct game logic for GuessTheSound', () {
      final logic = GameLogicFactory.getGameLogicForQuestionType('sound');
      expect(logic.gameModeName, 'Audio Quiz');
      expect(logic.supportsQuestionType('sound'), true);
      expect(logic.supportsQuestionType('music'), true);
    });

    test('should return correct game logic for GuessTheMusic', () {
      final logic = GameLogicFactory.getGameLogicForQuestionType('music');
      expect(logic.gameModeName, 'Audio Quiz');
      expect(logic.supportsQuestionType('sound'), true);
      expect(logic.supportsQuestionType('music'), true);
    });

    test('should return correct game logic for TrueOrFalse', () {
      final logic = GameLogicFactory.getGameLogicForQuestionType('truefalse');
      expect(logic.gameModeName, 'True or False');
      expect(logic.supportsQuestionType('truefalse'), true);
      expect(logic.supportsQuestionType('sound'), false);
    });

    test('should return correct game logic for Vocabulary', () {
      final logic = GameLogicFactory.getGameLogicForQuestionType('vocabulary');
      expect(logic.gameModeName, 'Vocabulary Quiz');
      expect(logic.supportsQuestionType('vocabulary'), true);
      expect(logic.supportsQuestionType('sound'), false);
    });

    test('should get correct game mode for questions', () {
      final soundQuestions = [
        {'type': 'sound', 'mode': 'GuessTheSound'},
        {'type': 'sound', 'mode': 'GuessTheSound'},
      ];
      
      final musicQuestions = [
        {'type': 'music', 'mode': 'GuessTheMusic'},
        {'type': 'music', 'mode': 'GuessTheMusic'},
      ];
      
      final trueFalseQuestions = [
        {'type': 'truefalse', 'mode': 'TrueOrFalse'},
        {'type': 'truefalse', 'mode': 'TrueOrFalse'},
      ];
      
      final vocabularyQuestions = [
        {'type': 'vocabulary', 'mode': 'Vocabulary'},
        {'type': 'vocabulary', 'mode': 'Vocabulary'},
      ];

      expect(GameModeSelector.selectGameModeForQuestions(soundQuestions), 'GuessTheSound');
      expect(GameModeSelector.selectGameModeForQuestions(musicQuestions), 'GuessTheMusic');
      expect(GameModeSelector.selectGameModeForQuestions(trueFalseQuestions), 'TrueOrFalse');
      expect(GameModeSelector.selectGameModeForQuestions(vocabularyQuestions), 'Vocabulary');
    });

    test('should check game mode compatibility', () {
      final soundQuestions = [
        {'type': 'sound', 'mode': 'GuessTheSound'},
      ];
      
      final trueFalseQuestions = [
        {'type': 'truefalse', 'mode': 'TrueOrFalse'},
      ];

      expect(GameModeSelector.areQuestionsCompatibleWithMode(soundQuestions, 'GuessTheSound'), true);
      expect(GameModeSelector.areQuestionsCompatibleWithMode(soundQuestions, 'TrueOrFalse'), false);
      expect(GameModeSelector.areQuestionsCompatibleWithMode(trueFalseQuestions, 'TrueOrFalse'), true);
      expect(GameModeSelector.areQuestionsCompatibleWithMode(trueFalseQuestions, 'GuessTheSound'), false);
    });

    test('should get available game modes', () {
      final gameModes = GameLogicFactory.getAvailableGameModes();
      expect(gameModes.length, 4);
      
      final modeIds = gameModes.map((mode) => mode.id).toSet();
      expect(modeIds.contains('GuessTheSound'), true);
      expect(modeIds.contains('GuessTheMusic'), true);
      expect(modeIds.contains('TrueOrFalse'), true);
      expect(modeIds.contains('Vocabulary'), true);
    });
  });
} 