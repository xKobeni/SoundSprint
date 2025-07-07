import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/sound_question.dart';
import 'game_logic/image_game_logic.dart';

void main() {
  group('ImageGameLogic Tests', () {
    late ImageGameLogic imageGameLogic;

    setUp(() {
      imageGameLogic = ImageGameLogic();
    });

    tearDown(() {
      imageGameLogic.dispose();
    });

    test('should support image question type', () {
      expect(imageGameLogic.supportsQuestionType('image'), isTrue);
      expect(imageGameLogic.supportsQuestionType('sound'), isFalse);
      expect(imageGameLogic.supportsQuestionType('music'), isFalse);
      expect(imageGameLogic.supportsQuestionType('truefalse'), isFalse);
      expect(imageGameLogic.supportsQuestionType('vocabulary'), isFalse);
    });

    test('should have correct game mode properties', () {
      expect(imageGameLogic.gameModeName, equals('Image Quiz'));
      expect(imageGameLogic.gameModeDescription, 
        equals('Look at the image and choose the correct answer from multiple options.'));
      expect(imageGameLogic.gameModeIcon, equals(Icons.image));
    });

    test('should initialize correctly', () async {
      await imageGameLogic.initialize();
      // No specific state to check, just ensure no exceptions
    });

    test('should handle correct answer', () async {
      final question = Question(
        mode: 'GuessTheImage',
        category: 'Philippine National Heroes',
        difficulty: 'Easy',
        type: 'image',
        file: 'heroes/jose_rizal.jpg',
        options: ['Jose Rizal', 'Andres Bonifacio', 'Lapu-Lapu', 'Emilio Aguinaldo'],
        correctAnswer: 'Jose Rizal',
      );

      await imageGameLogic.startQuestion(question);
      final result = await imageGameLogic.handleAnswer('Jose Rizal', question);
      
      expect(result, isTrue);
    });

    test('should handle incorrect answer', () async {
      final question = Question(
        mode: 'GuessTheImage',
        category: 'Philippine National Heroes',
        difficulty: 'Easy',
        type: 'image',
        file: 'heroes/jose_rizal.jpg',
        options: ['Jose Rizal', 'Andres Bonifacio', 'Lapu-Lapu', 'Emilio Aguinaldo'],
        correctAnswer: 'Jose Rizal',
      );

      await imageGameLogic.startQuestion(question);
      final result = await imageGameLogic.handleAnswer('Andres Bonifacio', question);
      
      expect(result, isFalse);
    });

    test('should throw error for unsupported question type', () async {
      final question = Question(
        mode: 'GuessTheSound',
        category: 'Animal Sound',
        difficulty: 'Easy',
        type: 'sound',
        file: 'dog_bark.wav',
        options: ['Dog', 'Cat', 'Cow', 'Sheep'],
        correctAnswer: 'Dog',
      );

      expect(
        () => imageGameLogic.startQuestion(question),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return correct time limit', () {
      final question = Question(
        mode: 'GuessTheImage',
        category: 'Philippine National Heroes',
        difficulty: 'Easy',
        type: 'image',
        file: 'heroes/jose_rizal.jpg',
        options: ['Jose Rizal', 'Andres Bonifacio', 'Lapu-Lapu', 'Emilio Aguinaldo'],
        correctAnswer: 'Jose Rizal',
      );

      expect(imageGameLogic.getTimeLimit(question), equals(20));
    });

    test('should build question widget', () {
      final question = Question(
        mode: 'GuessTheImage',
        category: 'Philippine National Heroes',
        difficulty: 'Easy',
        type: 'image',
        file: 'heroes/jose_rizal.jpg',
        options: ['Jose Rizal', 'Andres Bonifacio', 'Lapu-Lapu', 'Emilio Aguinaldo'],
        correctAnswer: 'Jose Rizal',
      );

      final widget = imageGameLogic.buildQuestionWidget(question, (answer) {});
      
      expect(widget, isA<Widget>());
    });
  });
} 