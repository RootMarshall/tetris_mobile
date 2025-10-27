# Tetris Mobile

A lightweight, aesthetic Tetris mobile game built with Flutter for Android.

## Features

### Core Gameplay
- Classic Tetris gameplay with all 7 tetromino types (I, O, T, S, Z, J, L)
- Three difficulty levels: **Beginner**, **Normal**, and **Hard**
- Progressive speed increase as you level up
- Lock delay mechanic - brief window to adjust pieces before they lock
- Local high score tracking with persistent storage

### Visual Polish
- Clean, modern UI with smooth animations
- Dramatic crumbling/exploding animation when clearing rows
- Celebratory "TETRIS" popup when clearing 4 lines at once
- Slam effect with visual feedback on hard drops
- Neon-styled grid with color-coded tetrominos

### Controls & Feedback
- Intuitive gesture-based controls
- Haptic feedback for rotations, holds, and slams
- **Tap anywhere**: Rotate piece clockwise
- **Swipe Left/Right**: Move piece horizontally
- **Swipe Down (slow)**: Soft drop (move down faster)
- **Swipe Down (fast)**: Hard drop with slam effect
- **Tap Hold Box**: Store current piece or swap with stored piece
- **Pause Button**: Top-right corner to pause/resume

### UI Features
- Menu screen with difficulty selection
- Real-time display of score, high score, level, and lines cleared
- Next piece preview
- Hold piece display (with visual indicator when unavailable)
- Game over screen with stats and option to retry or return to menu

## Installation

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install

2. Verify Flutter installation:
```bash
flutter doctor
```

3. Navigate to the project directory:
```bash
cd tetris_mobile
```

4. Get dependencies:
```bash
flutter pub get
```

5. Run on Android device/emulator:
```bash
flutter run
```

## Building for Release

To build an optimized APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

To build an app bundle (for Google Play):
```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
  ├── main.dart                    # App entry point
  ├── models/
  │   ├── tetromino.dart          # Tetromino shapes and rotations
  │   ├── game_board.dart         # Board state and logic
  │   └── game_state.dart         # Score, level, game status
  ├── game/
  │   ├── game_controller.dart    # Game loop and input handling
  │   └── collision_detector.dart # Collision detection logic
  ├── ui/
  │   ├── menu_screen.dart        # Main menu with difficulty selection
  │   ├── game_screen.dart        # Main game screen
  │   ├── board_widget.dart       # Render game board with animations
  │   ├── next_piece_widget.dart  # Show next tetromino
  │   ├── hold_box_widget.dart    # Show held tetromino (tappable)
  │   ├── tetris_popup.dart       # Celebratory TETRIS animation
  │   └── game_over_dialog.dart   # Game over screen with stats
  ├── services/
  │   └── high_score_service.dart # Persistent high score storage
  └── constants.dart              # Colors, sizes, speeds, difficulty settings
```

## Scoring

- 1 line: 40 points × level
- 2 lines: 100 points × level
- 3 lines: 300 points × level
- 4 lines (TETRIS): 1200 points × level

Level increases every 10 lines cleared, with progressively faster piece drops.

## Technical Details

### Requirements
- **Flutter SDK**: 3.0.0 or higher
- **Dart**: 2.19.0 or higher
- **Android SDK**: API level 21+ (Android 5.0 Lollipop or higher)
- **Java**: JDK 17 or higher (for building)
- **Gradle**: 8.4+ (included)

### Dependencies
- `flutter` - Core framework
- `shared_preferences` - Local high score persistence

### Performance
- Target: 60 FPS gameplay
- Estimated APK size: 12-15 MB (release build)
- Minimal memory footprint
- No network permissions required

## Game Mechanics

### Difficulty Levels
- **Beginner**: 800ms initial drop speed
- **Normal**: 600ms initial drop speed  
- **Hard**: 400ms initial drop speed

Speed increases by 10% with each level (every 10 lines cleared).

### Lock Delay
When a piece lands, you have 500ms to make up to 15 adjustments (move/rotate) before it locks permanently.

## Screenshots

_Coming soon - gameplay screenshots_

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

MIT License

