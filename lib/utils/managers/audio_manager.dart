import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Audio player instances
  final Map<String, AudioPlayer> _players = {};
  final Map<String, String> _cachedFiles = {};
  final Map<String, bool> _assetExists = {};
  final Map<String, Completer<void>> _preloadCompleters = {};
  
  // Settings
  double _volume = 0.5;
  bool _isMuted = false;
  bool _isPreloading = false;
  
  // Error tracking
  final Set<String> _missingAssets = {};
  final Map<String, int> _errorCounts = {};

  AudioPlayer? _currentPlayer; // Track the currently playing audio player

  /// Initialize the audio manager
  Future<void> initialize() async {
    if (_isPreloading) return;
    
    try {
      await _loadSettings();
      await _validateAssets();
      await _preloadCriticalAssets();
      
      // Check for missing audio files
      await getMissingAudioFiles();
    } catch (e) {
      debugPrint('AudioManager initialization error: $e');
    }
  }

  /// Load user audio settings
  Future<void> _loadSettings() async {
    // This would typically load from SharedPreferences
    // For now, using default values
    _volume = 0.5;
    _isMuted = false;
  }

  /// Validate that all referenced audio assets exist
  Future<void> _validateAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      debugPrint('=== Audio Asset Validation ===');
      
      // Check sounds directory
      final soundFiles = manifestMap.keys.where((key) => key.startsWith('assets/sounds/')).toList();
      debugPrint('Found ${soundFiles.length} sound files in manifest:');
      for (final file in soundFiles) {
        final fileName = file.split('/').last;
        _assetExists[fileName] = true;
        debugPrint('  ✓ $fileName');
      }
      
      // Check music directory
      final musicFiles = manifestMap.keys.where((key) => key.startsWith('assets/music/')).toList();
      debugPrint('Found ${musicFiles.length} music files in manifest:');
      for (final file in musicFiles) {
        final fileName = file.split('/').last;
        _assetExists[fileName] = true;
        debugPrint('  ✓ $fileName');
      }
      
      // Manually verify critical assets
      final criticalAssets = ['dog_bark.wav'];
      for (final asset in criticalAssets) {
        if (!_assetExists.containsKey(asset)) {
          try {
            await rootBundle.load('assets/sounds/$asset');
            _assetExists[asset] = true;
            debugPrint('  ✓ Manually verified: $asset');
          } catch (e) {
            debugPrint('  ✗ Asset not found: $asset - $e');
            _assetExists[asset] = false;
          }
        }
      }
      
      debugPrint('=== Asset Validation Complete ===');
      debugPrint('Available assets: ${_assetExists.keys.where((k) => _assetExists[k] == true).toList()}');
    } catch (e) {
      debugPrint('Error validating assets: $e');
    }
  }

  /// Preload critical audio assets for smoother gameplay
  Future<void> _preloadCriticalAssets() async {
    if (_isPreloading) return;
    _isPreloading = true;

    try {
      // Preload common sound effects
      final criticalSounds = ['dog_bark.wav']; // Add more as needed
      
      for (final sound in criticalSounds) {
        if (_assetExists[sound] == true) {
          await _preloadAsset('sounds/$sound');
        }
      }
    } catch (e) {
      debugPrint('Error preloading critical assets: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preload a specific audio asset
  Future<void> _preloadAsset(String assetPath) async {
    if (_preloadCompleters.containsKey(assetPath)) {
      return _preloadCompleters[assetPath]!.future;
    }

    final completer = Completer<void>();
    _preloadCompleters[assetPath] = completer;

    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource(assetPath));
      _players[assetPath] = player;
      _cachedFiles[assetPath] = assetPath;
      completer.complete();
    } catch (e) {
      debugPrint('Error preloading $assetPath: $e');
      completer.completeError(e);
    }
  }

  /// Play audio with robust error handling
  Future<bool> playAudio({
    required String fileName,
    required String type, // 'sound' or 'music'
    int? clipStart,
    int? clipEnd,
    String? playerId,
    String? category,
  }) async {
    try {
      String assetPath;
      if (type == 'sound') {
        // Map categories to subfolders
        if (category == 'Animal Sound') {
          assetPath = 'sounds/animals/$fileName';
        } else if (category == 'Nature Sound') {
          assetPath = 'sounds/nature/$fileName';
        } else if (category == 'Popular Memes Sound') {
          assetPath = 'sounds/popular_memes/$fileName';
        } else if (category == 'PH Meme Sound') {
          assetPath = 'sounds/ph_meme/$fileName';
        } else {
          assetPath = 'sounds/$fileName';
        }
      } else if (type == 'music' && category == 'Kpop Music') {
        assetPath = 'music/kpop/$fileName';
      } else if (type == 'music' && category == 'Anime Openings') {
        assetPath = 'music/anime/$fileName';
      } else {
        assetPath = 'music/$fileName';
      }
      final player = playerId != null ? _players[playerId] : null;
      
      // Check if asset exists
      if (_assetExists[fileName] != true) {
        _missingAssets.add(fileName);
        _errorCounts[fileName] = (_errorCounts[fileName] ?? 0) + 1;
        
        // For missing files, just return false instead of generating placeholder
        debugPrint('Audio file not found: $fileName');
        return false;
      }

      // Try to play from asset
      return await _playAsset(assetPath, clipStart, clipEnd, player);
    } catch (e) {
      debugPrint('Error playing audio $fileName: $e');
      _errorCounts[fileName] = (_errorCounts[fileName] ?? 0) + 1;
      return false;
    }
  }

  /// Play audio from asset
  Future<bool> _playAsset(String assetPath, int? clipStart, int? clipEnd, AudioPlayer? player) async {
    try {
      final audioPlayer = player ?? AudioPlayer();
      _currentPlayer = audioPlayer; // Track the current player
      // Set volume
      await audioPlayer.setVolume(_isMuted ? 0.0 : _volume);
      // Play the asset
      await audioPlayer.play(AssetSource(assetPath));
      // Handle clip timing for music
      if (clipStart != null) {
        await audioPlayer.seek(Duration(seconds: clipStart));
      }
      if (clipEnd != null && clipStart != null) {
        final duration = Duration(seconds: clipEnd - clipStart);
        Timer(duration, () {
          audioPlayer.stop();
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error playing asset $assetPath: $e');
      return false;
    }
  }

  /// Stop all audio playback
  Future<void> stopAll() async {
    // Stop all tracked players
    for (final player in _players.values) {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('Error stopping player: $e');
      }
    }
    // Stop the current player if not already stopped
    if (_currentPlayer != null) {
      try {
        await _currentPlayer!.stop();
        await _currentPlayer!.dispose();
      } catch (e) {
        debugPrint('Error stopping current player: $e');
      }
      _currentPlayer = null;
    }
  }

  /// Set volume for all players
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    
    for (final player in _players.values) {
      try {
        await player.setVolume(_isMuted ? 0.0 : _volume);
      } catch (e) {
        debugPrint('Error setting volume: $e');
      }
    }
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await setVolume(_volume);
  }

  /// Get audio statistics
  Map<String, dynamic> getAudioStats() {
    return {
      'totalAssets': _assetExists.length,
      'availableAssets': _assetExists.values.where((exists) => exists).length,
      'missingAssets': _missingAssets.length,
      'cachedFiles': _cachedFiles.length,
      'preloadedAssets': _players.length,
      'errorCounts': _errorCounts,
      'isPreloading': _isPreloading,
    };
  }

  /// Get missing assets list
  List<String> getMissingAssets() {
    return List.from(_missingAssets);
  }

  /// Get list of all audio files referenced in questions.json that are missing
  Future<List<String>> getMissingAudioFiles() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Get all available audio files
      final availableFiles = <String>{};
      final soundFiles = manifestMap.keys.where((key) => key.startsWith('assets/sounds/')).toList();
      final musicFiles = manifestMap.keys.where((key) => key.startsWith('assets/music/')).toList();
      
      for (final file in soundFiles) {
        availableFiles.add(file.split('/').last);
      }
      for (final file in musicFiles) {
        availableFiles.add(file.split('/').last);
      }
      
      // Load questions.json to see what files are referenced
      final questionsContent = await rootBundle.loadString('assets/data/questions.json');
      final Map<String, dynamic> questionsData = json.decode(questionsContent);
      
      final referencedFiles = <String>{};
      _extractAudioFiles(questionsData, referencedFiles);
      
      // Find missing files
      final missingFiles = referencedFiles.difference(availableFiles).toList();
      
      debugPrint('=== Missing Audio Files ===');
      debugPrint('Referenced files: ${referencedFiles.toList()}');
      debugPrint('Available files: ${availableFiles.toList()}');
      debugPrint('Missing files: $missingFiles');
      
      return missingFiles;
    } catch (e) {
      debugPrint('Error getting missing audio files: $e');
      return [];
    }
  }
  
  /// Recursively extract audio file names from questions data
  void _extractAudioFiles(dynamic data, Set<String> files) {
    if (data is Map) {
      for (final value in data.values) {
        _extractAudioFiles(value, files);
      }
    } else if (data is List) {
      for (final item in data) {
        _extractAudioFiles(item, files);
      }
    } else if (data is String && (data.endsWith('.wav') || data.endsWith('.mp3'))) {
      files.add(data);
    }
  }

  /// Check if asset exists
  bool assetExists(String fileName) {
    return _assetExists[fileName] == true;
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await stopAll();
    
    for (final player in _players.values) {
      try {
        await player.dispose();
      } catch (e) {
        debugPrint('Error disposing player: $e');
      }
    }
    
    _players.clear();
    _cachedFiles.clear();
    _preloadCompleters.clear();
  }
} 