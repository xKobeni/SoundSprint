import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AudioTest {
  static Future<bool> testAudioFile(String assetPath) async {
    try {
      print('Testing audio file: $assetPath');
      final audioPlayer = AudioPlayer();
      
      // Check if asset exists
      try {
        await rootBundle.load(assetPath);
        print('  ✓ Asset exists in bundle');
      } catch (e) {
        print('  ✗ Asset not found in bundle: $e');
        return false;
      }
      
      // Try to play the audio
      await audioPlayer.play(AssetSource(assetPath));
      
      // Wait a bit to see if it plays
      await Future.delayed(const Duration(seconds: 2));
      
      final state = await audioPlayer.state;
      await audioPlayer.dispose();
      
      final success = state == PlayerState.playing;
      print('  ${success ? "✓" : "✗"} Audio playback: ${success ? "SUCCESS" : "FAILED"}');
      return success;
    } catch (e) {
      print('  ✗ Audio test failed: $e');
      return false;
    }
  }

  static Future<void> testDogBark() async {
    print('=== Testing dog_bark.wav ===');
    final success = await testAudioFile('assets/sounds/dog_bark.wav');
    print('Dog bark test result: ${success ? 'SUCCESS' : 'FAILED'}');
    print('==============================');
  }
  
  static Future<void> testAllAvailableAudio() async {
    print('=== Testing All Available Audio Files ===');
    
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final soundFiles = manifestMap.keys.where((key) => key.startsWith('assets/sounds/')).toList();
      final musicFiles = manifestMap.keys.where((key) => key.startsWith('assets/music/')).toList();
      
      final allFiles = [...soundFiles, ...musicFiles];
      
      if (allFiles.isEmpty) {
        print('No audio files found in assets!');
        return;
      }
      
      for (final file in allFiles) {
        await testAudioFile(file);
        await Future.delayed(const Duration(seconds: 1)); // Wait between tests
      }
      
      print('=== Audio Testing Complete ===');
    } catch (e) {
      print('Error testing audio files: $e');
    }
  }
} 