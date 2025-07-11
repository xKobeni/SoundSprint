import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

class UserPreferences extends ChangeNotifier {
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();

  String? _avatarPath;
  String _displayName = '';
  int _points = 0;
  int _level = 1;

  String? get avatarPath => _avatarPath;
  String get displayName => _displayName;
  int get points => _points;
  int get level => _level;

  /// Initialize user preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarPath = prefs.getString('avatarPath');
    _displayName = prefs.getString('displayName') ?? '';
    _points = prefs.getInt('points') ?? 0;
    _level = prefs.getInt('level') ?? 1;
  }

  /// Points system
  Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt('points') ?? 0;
    return _points;
  }

  Future<void> setPoints(int value) async {
    final prefs = await SharedPreferences.getInstance();
    _points = value;
    await prefs.setInt('points', value);
    notifyListeners();
  }

  Future<void> addPoints(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt('points') ?? 0;
    _points = currentPoints + value;
    await prefs.setInt('points', _points);
    
    // Debug logging
    debugPrint('=== GLOBAL POINTS UPDATE ===');
    debugPrint('Previous Points: $currentPoints');
    debugPrint('Points Added: $value');
    debugPrint('New Total Points: $_points');
    debugPrint('=== END GLOBAL POINTS UPDATE ===');
    
    notifyListeners();
  }

  /// Update avatar path and notify listeners
  Future<void> updateAvatarPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('avatarPath', path);
    } else {
      await prefs.remove('avatarPath');
    }
    _avatarPath = path;
    notifyListeners();
  }

  /// Update display name and notify listeners
  Future<void> updateDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', name);
    _displayName = name;
    notifyListeners();
  }

  // Check if this is the first time the app is launched
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_time') ?? true;
  }

  // Mark that the user has completed onboarding
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }

  /// Get user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('displayName') ?? '';
    final age = prefs.getInt('age') ?? 18;
    final createdAtStr = prefs.getString('createdAt');
    
    if (name.isNotEmpty) {
      return User(
        name: name,
        age: age,
        createdAt: createdAtStr != null 
            ? DateTime.parse(createdAtStr) 
            : DateTime.now(),
      );
    }
    return null;
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', user.name);
    await prefs.setInt('age', user.age);
    await prefs.setString('createdAt', user.createdAt.toIso8601String());
    
    // Update the singleton instance
    _displayName = user.name;
    notifyListeners();
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('displayName');
    await prefs.remove('age');
    await prefs.remove('avatarPath');
    await prefs.remove('createdAt');
    
    // Update the singleton instance
    _displayName = '';
    _avatarPath = null;
    notifyListeners();
  }

  Future<void> setLevel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    _level = value;
    await prefs.setInt('level', value);
    notifyListeners();
  }

  Future<void> addLevel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    _level = (prefs.getInt('level') ?? 1) + value;
    await prefs.setInt('level', _level);
    notifyListeners();
  }
} 