# SoundSprint - Flutter Application Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Game Modes](#game-modes)
5. [Data Models](#data-models)
6. [Managers & Services](#managers--services)
7. [Pages & Navigation](#pages--navigation)
8. [Game Logic](#game-logic)
9. [Audio System](#audio-system)
10. [Achievement System](#achievement-system)
11. [User Interface](#user-interface)
12. [Assets & Resources](#assets--resources)
13. [Testing](#testing)
14. [Technical Implementation](#technical-implementation)

---

## Overview

**SoundSprint** is a comprehensive Flutter-based educational game application that focuses on audio recognition, music appreciation, and interactive learning. The app features multiple game modes, an achievement system, user progression, and accessibility features.

## Objectives

### Primary Objectives
1. **Educational Enhancement**: Improve users' auditory recognition skills, music appreciation, and cognitive abilities through interactive gameplay
2. **Accessibility**: Provide an inclusive gaming experience for users of all ages and abilities, including those with special needs
3. **Engagement**: Create a compelling, long-term engagement system through achievements, daily rewards, and progressive difficulty
4. **Cultural Appreciation**: Promote understanding and appreciation of diverse cultural content, including Filipino culture, K-pop, anime, and international music
5. **Skill Development**: Foster critical thinking, quick decision-making, and memory retention through timed challenges

### Key Features
- **Multiple Game Modes**: Audio recognition, music identification, true/false questions, vocabulary challenges, and image-based games
- **Progressive Difficulty**: Adaptive difficulty system with Easy, Medium, and Hard levels
- **Achievement System**: Comprehensive achievement tracking with 50+ unlockable achievements
- **Audio Management**: Robust audio playback with support for various audio formats
- **User Statistics**: Detailed tracking of user performance and progress
- **Accessibility**: Built-in accessibility features for inclusive gaming
- **Daily Rewards**: Daily points system to encourage regular engagement

---

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point and configuration
├── models/                   # Data models
│   ├── achievement.dart      # Achievement data structure
│   ├── sound_question.dart   # Question data structure
│   └── user.dart            # User profile data
├── pages/                    # UI screens
│   ├── splash_page.dart      # Loading screen
│   ├── onboarding_page.dart  # First-time user setup
│   ├── main_navigation_page.dart # Tab navigation
│   ├── home_page.dart        # Main dashboard
│   ├── game_selection_page.dart # Game mode selection
│   ├── category_selection_page.dart # Category selection
│   ├── game_page.dart        # Main gameplay screen
│   ├── result_page.dart      # Game results display
│   ├── stats_page.dart       # User statistics
│   ├── profile_page.dart     # User profile
│   ├── settings_page.dart    # App settings
│   └── achievements_page.dart # Achievement display
├── utils/                    # Business logic and utilities
│   ├── managers/             # State management and services
│   ├── game_logic/           # Game mode implementations
│   ├── tests/                # Unit and integration tests
│   └── question_loader.dart  # Data loading utilities
└── widgets/                  # Reusable UI components
    ├── answer_option_button.dart
    ├── bottom_nav_bar.dart
    ├── question_card.dart
    ├── sound_preview_widget.dart
    ├── tutorial_overlay.dart
    └── permission_utils.dart
```

### Design Patterns
- **Manager Pattern**: Centralized state management through specialized manager classes
- **Factory Pattern**: Game logic factory for creating appropriate game mode instances
- **Observer Pattern**: ChangeNotifier for reactive UI updates
- **Strategy Pattern**: Different game logic implementations for various game modes

---

## Features

### Core Gameplay
1. **Multi-Modal Learning**: Support for audio, visual, and text-based questions
2. **Adaptive Difficulty**: Dynamic difficulty progression based on user performance
3. **Real-time Feedback**: Immediate feedback on answers with visual and audio cues
4. **Timer System**: Configurable time limits based on difficulty level
5. **Progress Tracking**: Comprehensive tracking of user performance metrics

### User Experience
1. **Onboarding Flow**: Guided first-time user experience with age categorization
2. **Personalized Content**: Age-appropriate content and difficulty scaling
3. **Tutorial System**: Interactive tutorials for new features and game modes
4. **Accessibility Support**: Screen reader support, high contrast modes, and audio descriptions
5. **Offline Capability**: Core functionality works without internet connection

### Social & Engagement
1. **Achievement System**: 50+ achievements across multiple categories
2. **Daily Challenges**: Daily points system with rewards
3. **Statistics Dashboard**: Detailed performance analytics
4. **Progress Visualization**: Visual progress indicators and charts
5. **Notification System**: In-app notifications for achievements and daily rewards

---

## Game Modes

### 1. Guess The Sound (`GuessTheSound`)
- **Description**: Audio recognition game for various sound categories
- **Categories**: Animal sounds, nature sounds, Filipino memes, popular memes
- **Mechanics**: Play audio clip, select correct answer from multiple choices
- **Difficulty Levels**: Easy (20s), Medium (12s), Hard (9s)

### 2. Guess The Music (`GuessTheMusic`)
- **Description**: Music identification game
- **Categories**: K-pop, Anime openings, OPM (Original Pilipino Music)
- **Mechanics**: Play music clip, identify song title or artist
- **Features**: Support for audio clips with start/end timestamps

### 3. True or False (`TrueOrFalse`)
- **Description**: Fact-based true/false questions
- **Topics**: General knowledge, music facts, cultural information
- **Mechanics**: Read question, select true or false
- **Scoring**: Binary scoring system

### 4. Vocabulary (`Vocabulary`)
- **Description**: Language learning and vocabulary building
- **Content**: Word definitions, translations, context usage
- **Mechanics**: Multiple choice questions about word meanings
- **Educational Focus**: Language development and comprehension

### 5. Guess The Image (`GuessTheImage`)
- **Description**: Visual recognition game
- **Content**: Historical figures, cultural icons, landmarks
- **Mechanics**: View image, select correct identification
- **Categories**: Philippine heroes, international figures, cultural symbols

---

## Data Models

### Achievement Model
```dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String iconName;
  final int requirement;
  final String type; // 'score', 'streak', 'games', 'accuracy', 'category', 'difficulty'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;
}
```

### Question Model
```dart
class Question {
  final String mode;
  final String category;
  final String difficulty;
  final String? type; // 'sound', 'music', 'truefalse', 'vocabulary'
  final String? file;
  final int? clipStart;
  final int? clipEnd;
  final List<String>? options;
  final String? correctAnswer;
  final String? question; // for true/false and vocabulary
  final bool? answer; // for true/false
}
```

### User Model
```dart
class User {
  final String name;
  final int age;
  final DateTime createdAt;
}
```

---

## Managers & Services

### GameManager
- **Purpose**: Central game state management
- **Features**:
  - Question loading and progression
  - Score tracking and calculation
  - Timer management
  - Game logic coordination
  - Result generation
- **Key Methods**:
  - `loadQuestions()`: Load questions based on criteria
  - `handleAnswer()`: Process user answers
  - `getGameResult()`: Generate final game results
  - `startCurrentQuestion()`: Begin new question

### AudioManager
- **Purpose**: Comprehensive audio playback management
- **Features**:
  - Multi-format audio support (MP3, WAV)
  - Asset validation and preloading
  - Error handling and fallback mechanisms
  - Volume control and muting
  - Clip playback with start/end timestamps
- **Key Methods**:
  - `playAudio()`: Play audio with robust error handling
  - `forceStopAll()`: Emergency stop all audio
  - `preloadAsset()`: Preload critical audio assets

### AchievementManager
- **Purpose**: Achievement system management
- **Features**:
  - 50+ predefined achievements
  - Progress tracking across multiple categories
  - Achievement unlocking logic
  - Persistent storage with SharedPreferences
- **Achievement Categories**:
  - Score-based achievements
  - Streak-based achievements
  - Game count achievements
  - Accuracy achievements
  - Category-specific achievements
  - Difficulty-based achievements

### StatsManager
- **Purpose**: User statistics and analytics
- **Features**:
  - Performance tracking across all game modes
  - Accuracy calculations
  - Time-based statistics
  - Category-specific analytics
  - Progress visualization data

### DifficultyProgressionManager
- **Purpose**: Adaptive difficulty system
- **Features**:
  - Performance-based difficulty adjustment
  - Level progression tracking
  - Difficulty scaling algorithms
  - User skill assessment

### DailyPointsManager
- **Purpose**: Daily engagement system
- **Features**:
  - Daily point calculations
  - Streak tracking
  - Reward distribution
  - Engagement incentives

---

## Pages & Navigation

### SplashPage
- **Purpose**: Initial loading screen
- **Features**:
  - 3-second loading simulation
  - First-time user detection
  - Asset preloading
  - Smooth transition animations

### OnboardingPage
- **Purpose**: New user setup
- **Features**:
  - Name input with validation
  - Age selection with categories
  - Animated UI elements
  - User profile creation

### MainNavigationPage
- **Purpose**: Tab-based navigation
- **Features**:
  - Bottom navigation bar
  - State preservation across tabs
  - Smooth tab transitions

### GamePage
- **Purpose**: Main gameplay interface
- **Features**:
  - Dynamic question display
  - Timer countdown visualization
  - Answer selection interface
  - Progress indicators
  - Tutorial overlays

### ResultPage
- **Purpose**: Game completion summary
- **Features**:
  - Score display and analysis
  - Achievement notifications
  - Performance breakdown
  - Navigation options

---

## Game Logic

### BaseGameLogic
- **Purpose**: Abstract base class for all game modes
- **Key Methods**:
  - `startQuestion()`: Initialize question
  - `handleAnswer()`: Process user response
  - `getTimeLimit()`: Get time limit for question
  - `supportsQuestionType()`: Check compatibility

### AudioGameLogic
- **Purpose**: Audio-based game modes
- **Features**:
  - Audio playback management
  - Multiple choice answer handling
  - Audio clip timing control
  - Error handling for missing audio files

### TrueFalseGameLogic
- **Purpose**: True/false question handling
- **Features**:
  - Binary answer processing
  - Fact-based question display
  - Educational content integration

### VocabularyGameLogic
- **Purpose**: Language learning questions
- **Features**:
  - Word definition handling
  - Context-based questions
  - Educational content management

### ImageGameLogic
- **Purpose**: Visual recognition games
- **Features**:
  - Image display and management
  - Visual question processing
  - Image-based answer validation

---

## Audio System

### Audio Categories
1. **Animal Sounds**: Dog, cat, cow, horse, bear, fox, owl, pig, rooster, sheep, wolf, duck
2. **Nature Sounds**: Birds, cricket, fire, ice break, lava, rain, river, thunder, waterfall, wind
3. **Popular Memes**: 999 social credit, auughhh, bing chilling, cat laugh, DJ airhorn, frog laughing, goofy carhorn, hold up tiktok, imunderwater, john cena, Oh my god!, sad violin, super idol, sus, Vine boom, weeeee, wow
4. **Filipino Memes**: Bus vendor, dalawang beses nayan, filipino curses, ganda mo intro, Ge Talon, ice cream yummy, Lets Get Ready, mali ka nyan kapatid, Manny Pacquiao, milyon pans, pinoy oh no krinds, silly laugh, so weird, Taph Taph, tobol, uy boss, walang aawat
5. **K-pop Music**: aespa Savage, BIBI Vengeance, blackpink ddu du ddu du, BoA Only One, bts boy with luv, bts dynamite, EXO Love Shot, ITZY LOCO, ITZY WANNABE, IVE LOVE DIVE, momoland bboom bboom, NCT 127 Cherry Bomb, newjeans hypeboy, newjeans omg, Red Velvet Psycho, SEVENTEEN Super, Stray Kids Gods Menu, Taemin Move, twice fancy
6. **Anime Openings**: Bocchi The Rock, Chainsaw Man Op1, Cyberpunk Op1, Dandandan Op1, Fate Stay Night, Frieren Op1, Frieren Op2, Girls Band Cry, Girls Band Cry Void, Jujutsu Kaisen, Kusuriya No Hitorigoto S2, Lycoris Recoil, Mashle Op1, Rock Is A Lady Modesty, Zombie Land Saga

### Audio Features
- **Format Support**: MP3, WAV files
- **Clip Playback**: Start/end timestamp support
- **Preloading**: Critical assets preloaded for smooth gameplay
- **Error Handling**: Graceful fallback for missing files
- **Volume Control**: User-configurable volume settings
- **Mute Support**: Global and per-session muting

---

## Achievement System

### Achievement Categories

#### Score-Based Achievements
- **Perfect Score**: Get a perfect score in any game
- **High Scorer**: Score 80% or higher in 5 games
- **Excellent Player**: Score 90% or higher in 10 games
- **Master Player**: Score 95% or higher in 20 games

#### Streak-Based Achievements
- **Getting Started**: Win 2 games in a row
- **Getting Hot**: Maintain a 3-game winning streak
- **On Fire**: Maintain a 5-game winning streak
- **Unstoppable**: Maintain a 10-game winning streak
- **Legendary**: Maintain a 20-game winning streak

#### Game Count Achievements
- **Dedicated Player**: Play 10 games
- **Regular Player**: Play 25 games
- **Veteran Player**: Play 50 games
- **Century Club**: Play 100 games
- **Addicted**: Play 500 games

#### Accuracy Achievements
- **Good Listener**: Achieve 80% accuracy in a game
- **Sharp Ears**: Achieve 90% accuracy in a game
- **Perfect Pitch**: Achieve 100% accuracy in a game

#### Category-Specific Achievements
- **Animal Whisperer**: Complete 10 animal sound games
- **Nature Explorer**: Complete 10 nature sound games
- **Meme Master**: Complete 10 meme sound games
- **Music Lover**: Complete 10 music games
- **Vocabulary Expert**: Complete 10 vocabulary games

#### Difficulty-Based Achievements
- **Easy Rider**: Complete 20 easy games
- **Medium Master**: Complete 20 medium games
- **Hard Core**: Complete 20 hard games
- **Difficulty Explorer**: Complete games in all difficulty levels

### Achievement Features
- **Progress Tracking**: Real-time progress updates
- **Notification System**: Achievement unlock notifications
- **Persistent Storage**: Achievements saved locally
- **Icon System**: Diverse icon mapping for visual appeal
- **Unlock Timestamps**: Track when achievements were earned

---

## User Interface

### Design System
- **Primary Color**: `#7C5CFC` (Purple)
- **Secondary Color**: `#E9E0FF` (Light Purple)
- **Typography**: 
  - Headings: Fredoka font family
  - Body text: Poppins font family
- **Gradients**: Purple gradient backgrounds
- **Shadows**: Subtle drop shadows for depth

### Key Components

#### AnswerOptionButton
- **Purpose**: Interactive answer selection
- **Features**:
  - Hover and press animations
  - Correct/incorrect state indicators
  - Accessibility support
  - Custom styling options

#### QuestionCard
- **Purpose**: Display question content
- **Features**:
  - Dynamic content rendering
  - Audio preview integration
  - Image display support
  - Responsive layout

#### SoundPreviewWidget
- **Purpose**: Audio playback control
- **Features**:
  - Play/pause functionality
  - Progress visualization
  - Volume control
  - Clip timing display

#### TutorialOverlay
- **Purpose**: User guidance system
- **Features**:
  - Step-by-step tutorials
  - Interactive highlights
  - Dismissible overlays
  - Progress tracking

#### BottomNavBar
- **Purpose**: Main navigation
- **Features**:
  - Tab switching
  - Active state indicators
  - Smooth animations
  - Icon-based navigation

---

## Assets & Resources

### Audio Assets
- **Location**: `assets/sounds/` and `assets/music/`
- **Categories**:
  - `sounds/animals/`: Animal sound effects
  - `sounds/nature/`: Nature sound effects
  - `sounds/popular_memes/`: Popular internet memes
  - `sounds/ph_meme/`: Filipino meme sounds
  - `music/kpop/`: K-pop music tracks
  - `music/anime/`: Anime opening themes
  - `music/opm/`: Original Pilipino Music

### Image Assets
- **Location**: `assets/images/`
- **Categories**:
  - `images/heroes/`: Historical figures and heroes
  - `images/emp/`: Additional image content

### Font Assets
- **Location**: `assets/fonts/`
- **Fonts**:
  - **Fredoka**: Variable font for headings
  - **Poppins**: Font family for body text

### Data Assets
- **Location**: `assets/data/`
- **Files**:
  - `questions.json`: Comprehensive question database

---

## Testing

### Test Structure
```
lib/utils/tests/
├── audio_test.dart              # Audio functionality tests
├── game_logic_test.dart         # Game logic unit tests
├── category_accuracy_test.dart  # Category accuracy validation
├── image_game_logic_test.dart   # Image game logic tests
└── game_manager_disposal_test.dart # Resource cleanup tests
```

### Test Coverage
- **Audio System**: Audio playback, error handling, asset validation
- **Game Logic**: Question processing, answer validation, scoring
- **Category Accuracy**: Question categorization and difficulty assignment
- **Resource Management**: Memory cleanup and disposal
- **Integration**: End-to-end game flow testing

### Testing Features
- **Unit Tests**: Individual component testing
- **Integration Tests**: Multi-component interaction testing
- **Asset Validation**: Audio and image asset verification
- **Error Handling**: Graceful failure testing
- **Performance**: Memory usage and performance testing

---

## Technical Implementation

### State Management
- **ChangeNotifier**: Reactive state updates
- **Manager Pattern**: Centralized state management
- **SharedPreferences**: Persistent data storage
- **ListenableBuilder**: Efficient UI updates

### Performance Optimizations
- **Asset Preloading**: Critical assets loaded at startup
- **Lazy Loading**: Non-critical assets loaded on demand
- **Memory Management**: Proper disposal of audio players
- **Efficient Rendering**: Optimized widget rebuilds

### Error Handling
- **Graceful Degradation**: App continues functioning with missing assets
- **User Feedback**: Clear error messages and notifications
- **Fallback Mechanisms**: Alternative content when primary fails
- **Logging**: Comprehensive error logging for debugging

### Accessibility Features
- **Screen Reader Support**: Semantic labels and descriptions
- **High Contrast**: Alternative color schemes
- **Audio Descriptions**: Verbal feedback for visual content
- **Keyboard Navigation**: Full keyboard accessibility
- **Font Scaling**: Dynamic text size adjustment

### Platform Support
- **Android**: Full native Android support
- **iOS**: Complete iOS compatibility
- **Web**: Progressive Web App capabilities
- **Desktop**: Windows, macOS, and Linux support

### Dependencies
- **audioplayers**: Audio playback functionality
- **shared_preferences**: Local data persistence
- **overlay_support**: Notification overlays
- **flutter/foundation**: Debug utilities and platform detection

---

## Conclusion

SoundSprint is a comprehensive educational gaming application that successfully combines entertainment with learning. The modular architecture, robust audio system, comprehensive achievement system, and accessibility features make it suitable for users of all ages and abilities. The app demonstrates best practices in Flutter development, including proper state management, error handling, and performance optimization.

The application's strength lies in its diverse content, adaptive difficulty system, and engaging user experience. The achievement system provides long-term engagement, while the daily points system encourages regular usage. The comprehensive testing suite ensures reliability and maintainability.

Future enhancements could include:
- Multiplayer functionality
- Cloud synchronization
- Additional game modes
- Social features
- Advanced analytics
- Content creation tools
