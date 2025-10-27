# Tetris Mobile - Quick Start

## Installation (First Time)

### Step 1: Install Flutter
```bash
# Download Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### Step 2: Setup Android
```bash
# Accept licenses
flutter doctor --android-licenses
```

Install Android Studio from: https://developer.android.com/studio

### Step 3: Run the App
```bash
cd /Users/marshallmorgan/Projects/Tetris/tetris_mobile

# Get dependencies
flutter pub get

# Start emulator or connect device

# Run app
flutter run
```

## Daily Usage (After Setup)

```bash
# 1. Navigate to project
cd /Users/marshallmorgan/Projects/Tetris/tetris_mobile

# 2. Start emulator or connect device

# 3. Run app
flutter run
```

## Building Release APK

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

## Game Controls

- **Tap**: Rotate piece
- **Swipe Left/Right**: Move piece
- **Swipe Down**: Fast drop
- **HOLD Button**: Store/swap piece
- **DROP Button**: Instant drop
- **PAUSE Button**: Pause game

## Tips

1. Use HOLD to save a piece for the perfect moment
2. Clear 4 lines at once for maximum points (TETRIS)
3. Speed increases every 10 lines
4. Plan ahead using the NEXT piece preview

## Troubleshooting

**Problem**: flutter: command not found  
**Solution**: Add Flutter to PATH and restart terminal

**Problem**: No devices found  
**Solution**: Start Android emulator or connect phone with USB debugging

**Problem**: Build errors  
**Solution**: Run `flutter clean` then `flutter pub get`

## Project Structure

```
lib/
  ├── main.dart              # Entry point
  ├── constants.dart         # Colors & settings
  ├── models/               # Data models
  ├── game/                 # Game logic
  └── ui/                   # User interface
```

## Key Features

- Hold box to stash pieces
- TETRIS popup celebration
- Classic scoring system
- Progressive difficulty
- Smooth touch controls
- Lightweight (12-15MB)

## Documentation

- `README.md` - Full documentation
- `SETUP.md` - Detailed setup guide
- `FEATURES.md` - Feature overview
- `QUICKSTART.md` - This file

Enjoy playing Tetris!

