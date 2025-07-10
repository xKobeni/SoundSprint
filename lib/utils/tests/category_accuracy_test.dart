import 'package:flutter_test/flutter_test.dart';
import '../question_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Category Accuracy Tests', () {
    test('GuessTheSound should have correct difficulties and categories', () async {
      // Test GuessTheSound mode
      final difficulties = await QuestionLoader.getAvailableDifficulties(mode: 'GuessTheSound');
      expect(difficulties, containsAll(['Easy', 'Medium', 'Hard']));
      
      // Test categories for each difficulty
      final easyCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheSound', 
        difficulty: 'Easy'
      );
      expect(easyCategories, containsAll(['Filipino Memes Sound', 'Popular Memes Sound', 'Animal Sound']));
      expect(easyCategories, isNot(contains('Nature Sound')));
      
      final mediumCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheSound', 
        difficulty: 'Medium'
      );
      expect(mediumCategories, containsAll(['Filipino Memes Sound', 'Popular Memes Sound', 'Animal Sound', 'Nature Sound']));
      
      final hardCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheSound', 
        difficulty: 'Hard'
      );
      expect(hardCategories, containsAll(['Filipino Memes Sound', 'Popular Memes Sound', 'Animal Sound', 'Nature Sound']));
    });

    test('GuessTheMusic should have correct difficulties and categories', () async {
      // Test GuessTheMusic mode
      final difficulties = await QuestionLoader.getAvailableDifficulties(mode: 'GuessTheMusic');
      expect(difficulties, containsAll(['Easy', 'Medium', 'Hard']));
      
      // Test categories for each difficulty
      final easyCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheMusic', 
        difficulty: 'Easy'
      );
      expect(easyCategories, containsAll(['Kpop Music', 'Anime Openings', 'OPM Musics', 'Sample Music']));
      
      final mediumCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheMusic', 
        difficulty: 'Medium'
      );
      expect(mediumCategories, containsAll(['Kpop Music', 'Anime Openings', 'OPM Musics', 'Sample Music']));
      
      final hardCategories = await QuestionLoader.getAvailableCategories(
        mode: 'GuessTheMusic', 
        difficulty: 'Hard'
      );
      expect(hardCategories, containsAll(['Kpop Music', 'Anime Openings', 'OPM Musics', 'Sample Music']));
    });

    test('TrueOrFalse should have correct difficulties and categories', () async {
      // Test TrueOrFalse mode
      final difficulties = await QuestionLoader.getAvailableDifficulties(mode: 'TrueOrFalse');
      expect(difficulties, containsAll(['Easy', 'Medium', 'Hard']));
      
      // Test categories for each difficulty
      final easyCategories = await QuestionLoader.getAvailableCategories(
        mode: 'TrueOrFalse', 
        difficulty: 'Easy'
      );
      expect(easyCategories, containsAll(['General Knowledge', 'Science Facts']));
      
      final mediumCategories = await QuestionLoader.getAvailableCategories(
        mode: 'TrueOrFalse', 
        difficulty: 'Medium'
      );
      expect(mediumCategories, containsAll(['General Knowledge', 'Science Facts']));
      
      final hardCategories = await QuestionLoader.getAvailableCategories(
        mode: 'TrueOrFalse', 
        difficulty: 'Hard'
      );
      expect(hardCategories, containsAll(['General Knowledge', 'Science Facts']));
    });

    test('Vocabulary should have correct difficulties and categories', () async {
      // Test Vocabulary mode
      final difficulties = await QuestionLoader.getAvailableDifficulties(mode: 'Vocabulary');
      expect(difficulties, containsAll(['Easy', 'Medium', 'Hard']));
      
      // Test categories for each difficulty
      final easyCategories = await QuestionLoader.getAvailableCategories(
        mode: 'Vocabulary', 
        difficulty: 'Easy'
      );
      expect(easyCategories, containsAll(['English Synonyms']));
      expect(easyCategories, isNot(contains('Filipino-English Translation')));
      
      final mediumCategories = await QuestionLoader.getAvailableCategories(
        mode: 'Vocabulary', 
        difficulty: 'Medium'
      );
      expect(mediumCategories, containsAll(['Filipino-English Translation']));
      expect(mediumCategories, isNot(contains('English Synonyms')));
      
      final hardCategories = await QuestionLoader.getAvailableCategories(
        mode: 'Vocabulary', 
        difficulty: 'Hard'
      );
      expect(hardCategories, containsAll(['English Synonyms']));
      expect(hardCategories, isNot(contains('Filipino-English Translation')));
    });

    test('Question counts should be accurate', () async {
      // Test specific question counts
      final kpopEasyCount = await QuestionLoader.getQuestionCount(
        mode: 'GuessTheMusic',
        category: 'Kpop Music',
        difficulty: 'Easy'
      );
      expect(kpopEasyCount, equals(2));
      
      final natureEasyCount = await QuestionLoader.getQuestionCount(
        mode: 'GuessTheSound',
        category: 'Nature Sound',
        difficulty: 'Easy'
      );
      expect(natureEasyCount, equals(0)); // Nature Sound has no Easy questions
      
      final natureMediumCount = await QuestionLoader.getQuestionCount(
        mode: 'GuessTheSound',
        category: 'Nature Sound',
        difficulty: 'Medium'
      );
      expect(natureMediumCount, equals(1));
    });
  });
} 