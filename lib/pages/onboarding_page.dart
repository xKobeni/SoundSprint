import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/managers/user_preferences.dart';

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
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  bool _isButtonPressed = false;

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

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.1)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_iconAnimationController);
    _iconAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    _iconAnimationController.dispose();
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
          behavior: SnackBarBehavior.fixed,
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
    final Color accentColor = ageCategory['color'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const SizedBox(height: 24),
                  // Welcome Header
                  Column(
                    children: [
                      ScaleTransition(
                        scale: _iconScaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, accentColor.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.2),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to SoundSprint!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s get to know you better',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Name Input Label
                  const Text(
                    'Your Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C5CFC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Name Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: primaryColor.withOpacity(0.15),
                        width: 2,
                      ),
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
                  const SizedBox(height: 36),
                  // Age Section Title
                  const Text(
                    'Select Your Age',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7C5CFC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Age Slider Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: accentColor.withOpacity(0.18),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Age Category Display
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: ageCategory['color'].withOpacity(0.13),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ageCategory['color'],
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ageCategory['color'].withOpacity(0.08),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                ageCategory['emoji'],
                                style: const TextStyle(fontSize: 38),
                              ),
                              const SizedBox(width: 14),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ageCategory['label'],
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: ageCategory['color'],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${_ageValue.round()} years old',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: ageCategory['color'].withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
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
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
                            trackHeight: 7,
                            valueIndicatorColor: ageCategory['color'],
                            valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          child: Slider(
                            value: _ageValue,
                            min: 3,
                            max: 100,
                            divisions: 97,
                            label: _ageValue.round().toString(),
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
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '100',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  // Continue Button
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() => _isButtonPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isButtonPressed = false);
                      _completeOnboarding();
                    },
                    onTapCancel: () {
                      setState(() => _isButtonPressed = false);
                    },
                    child: AnimatedScale(
                      scale: _isButtonPressed ? 0.97 : 1.0,
                      duration: const Duration(milliseconds: 90),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.18),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start Your Sound Journey!',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
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
    )
    );
  }
} 