import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sound_question.dart';

class QuestionLoader {
  static Future<List<Question>> loadQuestions({String? mode, String? category, String? difficulty}) async {
    final String jsonString = await rootBundle.loadString('assets/data/questions.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    List<Question> allQuestions = [];

    // Traverse the nested structure
    for (final modeKey in jsonData.keys) {
      if (mode != null && mode.isNotEmpty && modeKey != mode) continue;
      final categories = jsonData[modeKey] as Map<String, dynamic>;
      for (final categoryKey in categories.keys) {
        if (category != null && category.isNotEmpty && categoryKey != category) continue;
        final difficulties = categories[categoryKey] as Map<String, dynamic>;
        for (final difficultyKey in difficulties.keys) {
          if (difficulty != null && difficulty.isNotEmpty && difficultyKey != difficulty) continue;
          final questionsList = difficulties[difficultyKey] as List<dynamic>;
          for (final questionData in questionsList) {
            final q = Question.fromJson(questionData);
            allQuestions.add(q);
          }
        }
      }
    }

    allQuestions.shuffle();
    return allQuestions;
  }

  /// Get available categories for a given mode
  static Future<List<String>> getAvailableCategories({String? mode}) async {
    final String jsonString = await rootBundle.loadString('assets/data/questions.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    Set<String> categories = {};
    if (mode != null && mode.isNotEmpty) {
      if (jsonData.containsKey(mode)) {
        categories.addAll((jsonData[mode] as Map<String, dynamic>).keys);
      }
    } else {
      for (final modeKey in jsonData.keys) {
        categories.addAll((jsonData[modeKey] as Map<String, dynamic>).keys);
      }
    }
    return categories.toList()..sort();
  }

  /// Get available difficulties for a specific mode and category
  static Future<List<String>> getAvailableDifficulties({String? mode, String? category}) async {
    final String jsonString = await rootBundle.loadString('assets/data/questions.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    Set<String> difficulties = {};
    if (mode != null && mode.isNotEmpty && category != null && category.isNotEmpty) {
      if (jsonData.containsKey(mode)) {
        final categories = jsonData[mode] as Map<String, dynamic>;
        if (categories.containsKey(category)) {
          difficulties.addAll((categories[category] as Map<String, dynamic>).keys);
        }
      }
    } else {
      for (final modeKey in jsonData.keys) {
        final categories = jsonData[modeKey] as Map<String, dynamic>;
        for (final categoryKey in categories.keys) {
          if (mode != null && mode.isNotEmpty && modeKey != mode) continue;
          if (category != null && category.isNotEmpty && categoryKey != category) continue;
          difficulties.addAll((categories[categoryKey] as Map<String, dynamic>).keys);
        }
      }
    }
    return difficulties.toList()..sort();
  }
} 