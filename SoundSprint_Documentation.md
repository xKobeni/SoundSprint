# SoundSprint · Hear It. Guess It. Win It!

---

## 📌 Project Overview
SoundSprint is an **offline, fast‑paced sound & music recognition quiz** built with Flutter.  
Players listen to short **sound effects (3‑5 s)** *or* **music excerpts (10‑30 s)** and choose the correct answer before the timer expires.  
The goal is to blend fun, learning, and rapid decision‑making in a lightweight, privacy‑friendly package.

---

## 🎯 Objectives
- Enhance auditory and musical recognition skills  
- Showcase Flutter’s offline multimedia capabilities  
- Provide an engaging, replayable game loop with local analytics  
- Facilitate future expansion: AI‑generated sounds, online multiplayer, cloud sync  

---

## 🕹️ Key Features

| Category | Details |
|----------|---------|
| **Gameplay** | Random sound **or 10–30 s music clip** <br> 4 multiple‑choice answers <br> 10 s countdown (sounds) / 30 s max (music) <br> Bonus points for quick answers <br> Instant visual & audio feedback |
| **Music Mode** | Dedicated question type that plays 10–30 s excerpts from instrumental or royalty‑free tracks located in `assets/music/` |
| **Local Analytics** | Tracks games played, high/average scores, most‑missed questions, per‑category accuracy, clip replay counts |
| **Audio Integration** | Uses `audioplayers` for gap‑free playback of both short SFX and longer music clips |
| **Offline‑First** | No network required post‑install; all data stored locally with `shared_preferences` |

---

## 🗂️ Project Structure

```text
lib/
├── main.dart                       # App entry & global navigation
├── pages/
│   ├── splash_page.dart            # (Optional) logo & asset pre‑loader
│   ├── home_page.dart              # Landing screen
│   ├── game_page.dart              # Core quiz logic
│   ├── result_page.dart            # Score summary
│   ├── stats_page.dart             # Analytics dashboard
│   ├── profile_page.dart           # User avatar, name & records
│   └── settings_page.dart          # Preferences (volume, theme, clip length) 
├── models/sound_question.dart      # Question data model
├── utils/analytics.dart            # Local analytics helper
└── providers/game_provider.dart    # State management (with Provider)

assets/
├── sounds/                         # Short sound effects (.mp3)
├── music/                          # 10‑30 s music clips (.mp3)
└── data/questions.json             # Question definitions
```

---

## 📱 App Pages

1. **Splash Page** – Optional animated logo while assets load.  
2. **Home Page** – Title, *Start Game* button, welcome user, stats preview, category buttons, nav drawer.  
3. **Game Page** – Plays sound/music clip, shows timer & options, handles scoring.  
4. **Result Page** – Final score, correct/incorrect breakdown, replay / home buttons.  
5. **Stats Page** – Charts & lists of local analytics (games, accuracy, misses).  
6. **Profile Page** – Avatar (optional via image picker), editable display name, lifetime high score & total playtime.  
7. **Settings Page** – Volume slider, theme toggle, preferred clip type (sound/music), clip length selector (10–30 s range), clear data option.

Navigation is managed via named routes in `main.dart` or `go_router` for cleaner URLs.

---

## ⚙️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^5.2.1          # Low‑latency audio
  shared_preferences: ^2.2.2    # Local key‑value storage
  provider: ^6.1.1              # State management
  image_picker: ^1.1.1          # (Optional) avatar selection on Profile Page
```

---

## 🧾 Data Format (`questions.json`)

```jsonc
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
    "clipStart": 12,            // seconds
    "clipEnd": 27,
    "options": ["Lofi Beats", "Jazz Groove", "Classical Mood", "Synth Wave"],
    "correctAnswer": "Lofi Beats"
  }
]
```

*For music questions, the player seeks to `clipStart` and stops at `clipEnd` (max 30 s).*

---

## 🔄 Gameplay Flow

1. Load questions & audio assets on startup (Splash → Home).  
2. Player taps **Start Game**.  
3. Random question served:  
   - If **sound**, play entire clip (≈3‑5 s) & start 10 s timer.  
   - If **music**, seek to `clipStart`, play up to 30 s & start 30 s timer.  
4. User selects an option or timer expires → give feedback & update score.  
5. Repeat until quiz length reached (e.g., 10 questions).  
6. Navigate to **Result Page** → offer replay or home.  
7. Persist analytics, update Profile stats.  

---

## 📊 Analytics Tracked

- Total & average score  
- Games played & total playtime  
- Per‑category accuracy (sound vs. music)  
- Most‑missed questions & replay counts  
- Highest streaks and fastest correct answer  
- Profile info: display name, avatar path  

All metrics stored **locally** with `shared_preferences` (or [`hive`](https://docs.hivedb.dev/) if you require complex querying).

---

## 🔐 Offline & Privacy

- All data stays on‑device; no external network calls.  
- Music clips must be royalty‑free/licensed for offline redistribution.  
- Optional Profile avatar remains local; not uploaded anywhere.  

---

## 🚀 Possible Extensions

- **AI Sound Generator** – Generate new SFX on‑device or via Hugging Face.  
- **Category Mode** – Filter by animals, instruments, movie quotes, music era.  
- **Firebase Sync** – Cloud backup of stats & leaderboard.  
- **Multiplayer** – LAN or online competitive mode.  

---

## ▶️ Quick Start

```bash
git clone https://github.com/yourname/soundsprint.git
cd soundsprint
# Add .mp3 clips to assets/sounds/ and assets/music/
# Add questions.json to assets/data/
flutter pub get
flutter run
```

---

## 👨‍💻 Developer Notes

- Built with Flutter **3.22 (stable)**.  
- Tested on Android 12 & iOS 17.  
- Uses **Provider** for lightweight state. Swap to **Riverpod** for bigger feature‑sets.  
- Keep music clips ≤ 30 s to minimize APK/IPA size & comply with fair‑use.  
- Adopt lazy asset loading for >100 MB bundles.

---

## 📜 License

MIT © 2025 Your Name
