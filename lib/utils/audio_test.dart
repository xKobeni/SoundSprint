import 'package:audioplayers/audioplayers.dart';

class AudioTest {
  static Future<bool> testAudioFile(String assetPath) async {
    try {
      final audioPlayer = AudioPlayer();
      await audioPlayer.play(AssetSource(assetPath));
      
      // Wait a bit to see if it plays
      await Future.delayed(const Duration(seconds: 2));
      
      final state = await audioPlayer.state;
      await audioPlayer.dispose();
      
      return state == PlayerState.playing;
    } catch (e) {
      print('Audio test failed for $assetPath: $e');
      return false;
    }
  }

  static Future<void> testDogBark() async {
    print('Testing dog_bark.wav...');
    final success = await testAudioFile('sounds/dog_bark.wav');
    print('Dog bark test result: ${success ? 'SUCCESS' : 'FAILED'}');
  }
} 