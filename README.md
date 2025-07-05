# SoundSprint · Hear It. Guess It. Win It!

A fast-paced offline sound & music recognition quiz built with Flutter. Test your auditory skills by identifying sounds and music clips in this engaging, privacy-friendly mobile game.

## 🎯 Features

- **Dual Game Modes**: Sound effects (3-5s) and music excerpts (10-30s)
- **Offline-First**: No internet required - all content stored locally
- **Fast-Paced Gameplay**: 10-second timer for sounds, 30-second timer for music
- **Local Analytics**: Track your progress, high scores, and accuracy
- **Multiple Choice**: 4 options per question with instant feedback
- **Bonus Scoring**: Earn extra points for quick answers
- **Privacy-Friendly**: All data stays on your device

## 🕹️ Gameplay

1. **Start a Game**: Choose from sound effects or music clips
2. **Listen & Guess**: Hear the audio and select the correct answer
3. **Beat the Timer**: Answer before time runs out for bonus points
4. **Track Progress**: View detailed statistics and improvement over time

## 📱 Screenshots

*Screenshots coming soon*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.22 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter_application_practice.git
   cd flutter_application_practice
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your audio content**
   - Place sound effects in `assets/sounds/` (3-5 second clips)
   - Place music clips in `assets/music/` (10-30 second excerpts)
   - Update `assets/data/questions.json` with your question data

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── pages/                       # App screens
│   ├── home_page.dart          # Main menu
│   ├── game_page.dart          # Quiz gameplay
│   ├── result_page.dart        # Score summary
│   ├── stats_page.dart         # Analytics dashboard
│   ├── profile_page.dart       # User profile
│   └── settings_page.dart      # App preferences
├── models/                      # Data models
├── utils/                       # Helper utilities
└── widgets/                     # Reusable UI components

assets/
├── sounds/                      # Sound effect files (.mp3)
├── music/                       # Music clip files (.mp3)
└── data/
    └── questions.json          # Question definitions
```

## 📊 Question Format

Questions are defined in `assets/data/questions.json`:

```json
[
  {
    "type": "sound",
    "soundFile": "animal_dog.mp3",
    "options": ["Dog", "Cat", "Cow", "Elephant"],
    "correctAnswer": "Dog"
  },
  {
    "type": "music",
    "musicFile": "lofi_beats.mp3",
    "clipStart": 12,
    "clipEnd": 27,
    "options": ["Lofi Beats", "Jazz Groove", "Classical Mood", "Synth Wave"],
    "correctAnswer": "Lofi Beats"
  }
]
```

## 🛠️ Dependencies

- **audioplayers**: Low-latency audio playback
- **shared_preferences**: Local data storage
- **provider**: State management
- **image_picker**: Profile avatar selection
- **connectivity_plus**: Network status monitoring
- **animated_text_kit**: Text animations
- **path_provider**: File system access

## 📈 Analytics

The app tracks various metrics locally:
- Total games played and scores
- Average accuracy per category
- Most-missed questions
- Personal bests and streaks
- Total playtime

## 🔐 Privacy & Offline

- **100% Offline**: No internet connection required
- **Local Storage**: All data stays on your device
- **No Tracking**: No analytics sent to external services
- **Privacy-First**: Your gameplay data belongs to you

## 🎵 Audio Requirements

- **Sound Effects**: 3-5 second MP3 files
- **Music Clips**: 10-30 second MP3 excerpts
- **Royalty-Free**: Ensure you have rights to use all audio content
- **File Size**: Keep files reasonably sized for app performance

## 🚀 Future Enhancements

- AI-generated sound effects
- Category-based gameplay modes
- Cloud sync for stats backup
- Multiplayer competitive mode
- Custom question creation
- Social sharing features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Development

Built with Flutter 3.22 and tested on:
- Android 12+
- iOS 17+
- Windows 10/11
- macOS 12+

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Review the [SoundSprint Documentation](SoundSprint_Documentation.md)

---

**Happy Gaming! 🎮🎵**
