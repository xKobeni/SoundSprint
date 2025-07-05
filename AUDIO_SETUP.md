# Audio Setup Guide for SoundSprint

## Current Status
Your app currently has:
- ✅ `assets/sounds/dog_bark.wav` - Working
- ❌ Many missing audio files referenced in `questions.json`

## Quick Fix Applied
I've updated your `questions.json` to only reference the `dog_bark.wav` file that you actually have. This means:
- All questions now use the same dog bark sound
- The app will work without errors
- You can test the gameplay mechanics

## How to Add More Audio Files

### Step 1: Prepare Your Audio Files
1. **Format**: Use `.wav` or `.mp3` files
2. **Duration**: 
   - Sound effects: 3-5 seconds
   - Music clips: 10-30 seconds
3. **Quality**: Keep file sizes reasonable (under 5MB each)

### Step 2: Add Files to Assets
1. Place sound effects in `assets/sounds/`
2. Place music clips in `assets/music/`
3. Make sure file names match what's in `questions.json`

### Step 3: Update Questions (Optional)
If you want to use different audio files, update `assets/data/questions.json`:

```json
{
  "GuessTheSound": {
    "Animal Sound": {
      "Easy": [
        {
          "mode": "GuessTheSound",
          "category": "Animal Sound",
          "difficulty": "Easy",
          "type": "sound",
          "file": "your_new_file.wav",
          "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
          "correctAnswer": "Option 1"
        }
      ]
    }
  }
}
```

### Step 4: Test Your Audio
Run the app and check the console output. You should see:
```
=== Audio Asset Validation ===
Found 1 sound files in manifest:
  ✓ your_new_file.wav
```

## Recommended Audio Files to Add

### Sound Effects (for `assets/sounds/`)
- `cat_meow.wav`
- `bird_chirp.wav`
- `car_horn.wav`
- `door_bell.wav`
- `phone_ring.wav`
- `footsteps.wav`
- `water_drop.wav`
- `wind_blow.wav`

### Music Clips (for `assets/music/`)
- `classical_piece.wav`
- `jazz_swing.wav`
- `rock_guitar.wav`
- `electronic_beats.wav`
- `folk_melody.wav`

## Troubleshooting

### Audio Not Playing?
1. Check console output for error messages
2. Verify file names match exactly (case-sensitive)
3. Ensure files are in the correct folders
4. Run `flutter clean` and `flutter pub get`

### Missing Files Error?
The app will show "Audio file not found" if files are missing. Add the files or update `questions.json` to only reference existing files.

### Testing Audio
Use the built-in test function:
```dart
await AudioTest.testDogBark(); // Tests existing file
await AudioTest.testAllAvailableAudio(); // Tests all files
```

## Legal Considerations
- Only use royalty-free audio files
- Ensure you have rights to use any audio content
- Consider using Creative Commons licensed content
- For commercial use, purchase proper licenses

## Quick Start with Placeholder Audio
If you want to test with more variety quickly:
1. Copy `dog_bark.wav` multiple times with different names
2. Update `questions.json` to reference these copies
3. This gives you multiple "different" sounds for testing

## Next Steps
1. Add a few audio files to test
2. Update `questions.json` to reference them
3. Test the gameplay
4. Gradually add more content

The app is now working with your existing `dog_bark.wav` file, so you can test all the game mechanics while you add more audio content! 