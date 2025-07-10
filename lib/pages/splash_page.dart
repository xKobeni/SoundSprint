import 'package:flutter/material.dart';
import '../utils/managers/user_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate asset loading or other startup tasks
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Check if this is the first time the app is launched
      final isFirstTime = await UserPreferences().isFirstTime();
      
      if (isFirstTime) {
        // New user - go to onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // Returning user - go to main navigation
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF7C5CFC);
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.music_note, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'SoundSprint',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 