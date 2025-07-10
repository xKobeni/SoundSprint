import 'package:flutter/material.dart';
import '../utils/managers/accessibility_manager.dart';
import '../utils/managers/tutorial_manager.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final String tutorialKey;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    Key? key,
    required this.child,
    required this.tutorialKey,
    required this.steps,
    this.onComplete,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _showTutorial() async {
    try {
      // Check if tutorial should be shown
      bool shouldShow = false;
      switch (widget.tutorialKey) {
        case 'game':
          shouldShow = !(await TutorialManager.isGameTutorialShown());
          break;
        case 'settings':
          shouldShow = !(await TutorialManager.isSettingsTutorialShown());
          break;
        case 'GuessTheSound':
        case 'GuessTheMusic':
        case 'TrueOrFalse':
        case 'Vocabulary':
        case 'GuessTheImage':
          shouldShow = !(await TutorialManager.isGameModeTutorialShown(widget.tutorialKey));
          break;
        default:
          shouldShow = !(await TutorialManager.isTutorialCompleted());
      }

      if (shouldShow && mounted) {
        setState(() {
          _isVisible = true;
        });
        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 100));
        _slideController.forward();
        await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.light);
      }
    } catch (e) {
      // If there's an error, don't show the tutorial
      debugPrint('Error showing tutorial: $e');
    }
  }

  void _nextStep() async {
    try {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.selection);

      if (_currentStep < widget.steps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _completeTutorial();
      }
    } catch (e) {
      debugPrint('Error in next step: $e');
    }
  }

  void _previousStep() async {
    try {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.selection);

      if (_currentStep > 0) {
        setState(() {
          _currentStep--;
        });
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      debugPrint('Error in previous step: $e');
    }
  }

  void _skipTutorial() async {
    try {
      await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.medium);
      _completeTutorial();
    } catch (e) {
      debugPrint('Error skipping tutorial: $e');
    }
  }

  void _completeTutorial() async {
    try {
      // Mark tutorial as completed
      switch (widget.tutorialKey) {
        case 'game':
          await TutorialManager.markGameTutorialShown();
          break;
        case 'settings':
          await TutorialManager.markSettingsTutorialShown();
          break;
        case 'GuessTheSound':
        case 'GuessTheMusic':
        case 'TrueOrFalse':
        case 'Vocabulary':
        case 'GuessTheImage':
          await TutorialManager.markGameModeTutorialShown(widget.tutorialKey);
          break;
        default:
          await TutorialManager.markTutorialCompleted();
      }

      if (mounted) {
        _slideController.reverse();
        await Future.delayed(const Duration(milliseconds: 400));
        _fadeController.reverse();
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _isVisible = false;
        });
      }

      widget.onComplete?.call();
    } catch (e) {
      debugPrint('Error completing tutorial: $e');
      // Even if there's an error, hide the tutorial
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildTutorialPopupCard(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTutorialPopupCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth * 0.85,
        constraints: BoxConstraints(
          maxWidth: 350,
          minWidth: 280,
          minHeight: 200,
          maxHeight: screenHeight * 0.5, // Changed from 0.8 to 0.5 for half-screen
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(screenWidth < 350 ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button and step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step indicators - make them more compact
                Flexible(
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.steps.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: i == _currentStep ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: i == _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _skipTutorial,
                  icon: const Icon(Icons.close, color: Colors.grey),
                  tooltip: 'Skip tutorial',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            // Page view for tutorial steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: widget.steps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialStep(widget.steps[index]);
                },
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.only(top: 12), // Reduced from 16 to 12
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep < widget.steps.length - 1 ? 'Next' : 'Get Started',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(TutorialStep step) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: isSmallScreen ? 50 : 60,
                height: isSmallScreen ? 50 : 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon ?? Icons.help_outline,
                  size: isSmallScreen ? 25 : 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            
            // Step title
            Text(
              step.title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            
            // Step description
            Text(
              step.description,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.black54,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData? icon;

  const TutorialStep({
    required this.title,
    required this.description,
    this.icon,
  });
}

class TutorialHelper {
  static List<TutorialStep> getGameTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Welcome to SoundSprint!',
        description: 'Test your audio recognition skills with fun sound and music quizzes.',
        icon: Icons.music_note,
      ),
      const TutorialStep(
        title: 'Listen Carefully',
        description: 'Each question plays an audio clip. Listen carefully as you only get one chance to hear it.',
        icon: Icons.hearing,
      ),
      const TutorialStep(
        title: 'Choose Your Answer',
        description: 'Select the correct answer from the four options before time runs out.',
        icon: Icons.touch_app,
      ),
      const TutorialStep(
        title: 'Watch the Timer',
        description: 'Sound questions give you 10 seconds, music questions up to 30 seconds to answer.',
        icon: Icons.timer,
      ),
      const TutorialStep(
        title: 'Track Your Progress',
        description: 'Check your stats to see how you\'re improving and identify areas to practice.',
        icon: Icons.analytics,
      ),
    ];
  }

  static List<TutorialStep> getSettingsTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Audio Settings',
        description: 'Adjust volume and test audio to ensure the best listening experience.',
        icon: Icons.volume_up,
      ),
      const TutorialStep(
        title: 'Data Management',
        description: 'Clear your data and reset your progress when needed.',
        icon: Icons.storage,
      ),
      const TutorialStep(
        title: 'Help & Support',
        description: 'Access help, FAQ, and troubleshooting guides anytime.',
        icon: Icons.help_outline,
      ),
    ];
  }

  static List<TutorialStep> getGuessTheSoundTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Guess The Sound',
        description: 'Listen to short sound effects and identify what made the sound.',
        icon: Icons.hearing,
      ),
      const TutorialStep(
        title: 'Quick Recognition',
        description: 'You have 10 seconds to identify each sound. Focus on the unique characteristics.',
        icon: Icons.timer,
      ),
      const TutorialStep(
        title: 'Multiple Categories',
        description: 'Practice with animal sounds, nature sounds, vehicles, and more.',
        icon: Icons.category,
      ),
      const TutorialStep(
        title: 'Improve Your Skills',
        description: 'Start with Easy difficulty and work your way up to Hard challenges.',
        icon: Icons.trending_up,
      ),
    ];
  }

  static List<TutorialStep> getGuessTheMusicTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Guess The Music',
        description: 'Listen to music excerpts and identify the song, artist, or genre.',
        icon: Icons.music_note,
      ),
      const TutorialStep(
        title: 'Extended Listening',
        description: 'You have up to 30 seconds to identify each piece of music.',
        icon: Icons.timer,
      ),
      const TutorialStep(
        title: 'Music Categories',
        description: 'Test your knowledge of anime, K-pop, OPM, and other music genres.',
        icon: Icons.music_note,
      ),
      const TutorialStep(
        title: 'Musical Memory',
        description: 'Pay attention to melodies, rhythms, and distinctive musical elements.',
        icon: Icons.psychology,
      ),
    ];
  }

  static List<TutorialStep> getTrueOrFalseTutorialSteps() {
    return [
      const TutorialStep(
        title: 'True or False',
        description: 'Answer questions about audio facts and concepts with True or False.',
        icon: Icons.check_circle_outline,
      ),
      const TutorialStep(
        title: 'Knowledge Based',
        description: 'Test your understanding of music theory, sound science, and audio concepts.',
        icon: Icons.school,
      ),
      const TutorialStep(
        title: 'Quick Decisions',
        description: 'You have 15 seconds to decide if each statement is True or False.',
        icon: Icons.timer,
      ),
      const TutorialStep(
        title: 'Learn as You Play',
        description: 'Expand your audio knowledge while having fun with this educational mode.',
        icon: Icons.lightbulb,
      ),
    ];
  }

  static List<TutorialStep> getVocabularyTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Vocabulary Challenge',
        description: 'Test your understanding of important terms and concepts through interactive questions.',
        icon: Icons.book,
      ),
      const TutorialStep(
        title: 'Educational Content',
        description: 'Explore Filipino words, technical concepts, and essential vocabulary.',
        icon: Icons.school,
      ),
      const TutorialStep(
        title: 'Multiple Choice',
        description: 'Select the correct definition or term from the possible options.',
        icon: Icons.format_list_bulleted,
      ),
      const TutorialStep(
        title: 'Build Your Knowledge',
        description: 'Grow your vocabulary and deepen your understanding of key concepts.',
        icon: Icons.trending_up,
      ),
    ];
  }

  static List<TutorialStep> getGuessTheImageTutorialSteps() {
    return [
      const TutorialStep(
        title: 'Guess The Image',
        description: 'Look at images and identify what they represent or relate to audio.',
        icon: Icons.image,
      ),
      const TutorialStep(
        title: 'Visual Recognition',
        description: 'Connect visual elements with their corresponding sounds or music.',
        icon: Icons.visibility,
      ),
      const TutorialStep(
        title: 'Audio-Visual Link',
        description: 'Match images to sounds, instruments, or musical concepts.',
        icon: Icons.link,
      ),
      const TutorialStep(
        title: 'Multi-Sensory Learning',
        description: 'Combine visual and audio learning for a comprehensive experience.',
        icon: Icons.psychology,
      ),
    ];
  }
} 