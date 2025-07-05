import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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
  final List<String> _missingAssets = [];
  final Map<String, int> _errorCounts = {};

  /// Initialize the audio manager
  Future<void> initialize() async {
    try {
      await _loadSettings();
      await _validateAssets();
      await _preloadCriticalAssets();
    } catch (e) {
      print('AudioManager initialization error: $e');
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
      
      // Check sounds directory
      final soundFiles = manifestMap.keys.where((key) => key.startsWith('assets/sounds/')).toList();
      for (final file in soundFiles) {
        final fileName = file.split('/').last;
        _assetExists[fileName] = true;
        print('Found sound asset: $fileName');
      }
      
      // Check music directory
      final musicFiles = manifestMap.keys.where((key) => key.startsWith('assets/music/')).toList();
      for (final file in musicFiles) {
        final fileName = file.split('/').last;
        _assetExists[fileName] = true;
        print('Found music asset: $fileName');
      }
      
      // Manually add known assets if they exist in the filesystem
      if (!_assetExists.containsKey('dog_bark.wav')) {
        try {
          await rootBundle.load('assets/sounds/dog_bark.wav');
          _assetExists['dog_bark.wav'] = true;
          print('Manually added dog_bark.wav to available assets');
        } catch (e) {
          print('dog_bark.wav not found in assets: $e');
          _assetExists['dog_bark.wav'] = false;
        }
      }
    } catch (e) {
      print('Error validating assets: $e');
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
      print('Error preloading critical assets: $e');
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
      print('Error preloading $assetPath: $e');
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
  }) async {
    try {
      final assetPath = type == 'sound' ? 'sounds/$fileName' : '$type/$fileName';
      final player = playerId != null ? _players[playerId] : null;
      
      // Check if asset exists
      if (_assetExists[fileName] != true) {
        _missingAssets.add(fileName);
        _errorCounts[fileName] = (_errorCounts[fileName] ?? 0) + 1;
        
        // For missing files, just return false instead of generating placeholder
        print('Audio file not found: $fileName');
        return false;
      }

      // Try to play from asset
      return await _playAsset(assetPath, clipStart, clipEnd, player);
    } catch (e) {
      print('Error playing audio $fileName: $e');
      _errorCounts[fileName] = (_errorCounts[fileName] ?? 0) + 1;
      return false;
    }
  }

  /// Play audio from asset
  Future<bool> _playAsset(String assetPath, int? clipStart, int? clipEnd, AudioPlayer? player) async {
    try {
      final audioPlayer = player ?? AudioPlayer();
      
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
      print('Error playing asset $assetPath: $e');
      return false;
    }
  }

  /// Stop all audio playback
  Future<void> stopAll() async {
    for (final player in _players.values) {
      try {
        await player.stop();
      } catch (e) {
        print('Error stopping player: $e');
      }
    }
  }

  /// Set volume for all players
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    
    for (final player in _players.values) {
      try {
        await player.setVolume(_isMuted ? 0.0 : _volume);
      } catch (e) {
        print('Error setting volume: $e');
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
        print('Error disposing player: $e');
      }
    }
    
    _players.clear();
    _cachedFiles.clear();
    _preloadCompleters.clear();
  }
} 