import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accessibility_manager.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;
  SettingsProvider._internal();

  // Audio Settings
  double _volume = 0.5;
  double get volume => _volume;

  // Theme data
  ThemeData? _currentTheme;
  ThemeData get currentTheme => _currentTheme ?? _getDefaultTheme();

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load settings
      _volume = prefs.getDouble('volume') ?? 0.5;

      // Generate theme
      _currentTheme = _generateTheme();
      
      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }

  /// Save setting to SharedPreferences and update app state
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }

      // Update local state based on key
      switch (key) {
        case 'volume':
          _volume = value;
          break;
      }

      // Notify listeners for real-time updates
      notifyListeners();
    } catch (e) {
      print('Error saving setting: $e');
    }
  }

  /// Generate theme based on current settings
  ThemeData _generateTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CFC)),
    );
  }

  /// Get default theme
  ThemeData _getDefaultTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CFC)),
    );
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset to defaults
      _volume = 0.5;
      
      _currentTheme = _generateTheme();
      
      notifyListeners();
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
} 