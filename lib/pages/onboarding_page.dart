import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/user_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  double _ageValue = 25.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _ageCategories = [
    {'min': 3, 'max': 7, 'label': 'Little Explorer', 'emoji': '🧒', 'color': Colors.blue},
    {'min': 8, 'max': 12, 'label': 'Young Adventurer', 'emoji': '👦', 'color': Colors.green},
    {'min': 13, 'max': 17, 'label': 'Teen Hero', 'emoji': '👨‍🎓', 'color': Colors.orange},
    {'min': 18, 'max': 25, 'label': 'Young Adult', 'emoji': '👨‍💼', 'color': Colors.purple},
    {'min': 26, 'max': 35, 'label': 'Professional', 'emoji': '👨‍💻', 'color': Colors.indigo},
    {'min': 36, 'max': 50, 'label': 'Experienced', 'emoji': '👨‍🏫', 'color': Colors.teal},
    {'min': 51, 'max': 65, 'label': 'Wise One', 'emoji': '👨‍🦳', 'color': Colors.brown},
    {'min': 66, 'max': 100, 'label': 'Legend', 'emoji': '👴', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getAgeCategory(double age) {
    final ageInt = age.round();
    for (var category in _ageCategories) {
      if (ageInt >= category['min'] && ageInt <= category['max']) {
        return category;
      }
    }
    return _ageCategories[3]; // Default to Young Adult
  }

  void _completeOnboarding() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = User(
      name: _nameController.text.trim(),
      age: _ageValue.round(),
      createdAt: DateTime.now(),
    );

    await UserPreferences().saveUser(user);
    await UserPreferences().markOnboardingComplete();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageCategory = _getAgeCategory(_ageValue);
    final Color primaryColor = const Color(0xFF7C5CFC);

    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  // Welcome Header
                  Column(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to SoundSprint!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s get to know you better',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  
                  // Name Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.person, color: Color(0xFF7C5CFC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Age Slider Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Age Category Display
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: ageCategory['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ageCategory['color'],
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ageCategory['emoji'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Text(
                                    ageCategory['label'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ageCategory['color'],
                                    ),
                                  ),
                                  Text(
                                    '${_ageValue.round()} years old',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ageCategory['color'].withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Age Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: ageCategory['color'],
                            inactiveTrackColor: ageCategory['color'].withOpacity(0.3),
                            thumbColor: ageCategory['color'],
                            overlayColor: ageCategory['color'].withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: _ageValue,
                            min: 3,
                            max: 100,
                            divisions: 97,
                            onChanged: (value) {
                              setState(() {
                                _ageValue = value;
                              });
                            },
                          ),
                        ),
                        
                        // Age Range Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '100',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Continue Button
                  ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start Your Sound Journey!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 