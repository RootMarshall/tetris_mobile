# Tetris Mobile Setup Guide

## Prerequisites

Before you can run this Tetris app, you need to install Flutter.

### Install Flutter SDK

1. **macOS Installation**:
   ```bash
   # Download Flutter SDK
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   
   # Add Flutter to PATH
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Add to your shell profile (~/.zshrc or ~/.bash_profile)
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```
   This will check your environment and show what's missing.

3. **Accept Android Licenses**:
   ```bash
   flutter doctor --android-licenses
   ```

### Android Studio Setup (Recommended)

1. Download Android Studio: https://developer.android.com/studio
2. During installation, install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device

3. Install Flutter plugin in Android Studio:
   - Open Android Studio
   - Go to Preferences > Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

### Create Android Emulator

1. Open Android Studio
2. Go to Tools > Device Manager
3. Click "Create Device"
4. Select a phone (e.g., Pixel 5)
5. Download and select a system image (e.g., Android 13)
6. Finish setup

## Running the App

1. **Navigate to project directory**:
   ```bash
   cd /Users/marshallmorgan/Projects/Tetris/tetris_mobile
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Start Android emulator** (or connect physical device)

4. **Check connected devices**:
   ```bash
   flutter devices
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## Building Release APK

To build an optimized APK for installation:

```bash
flutter build apk --release --split-per-abi
```

The APK will be at: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

Expected size: 12-15MB

## Troubleshooting

### "flutter: command not found"
- Make sure Flutter is in your PATH
- Restart your terminal
- Run: `export PATH="$PATH:$HOME/development/flutter/bin"`

### "No devices found"
- Start an Android emulator
- Or connect a physical Android device with USB debugging enabled

### "License not accepted"
- Run: `flutter doctor --android-licenses`
- Accept all licenses by typing 'y'

### Build errors
- Run: `flutter clean`
- Then: `flutter pub get`
- Try again: `flutter run`

## Next Steps

Once the app is running:
- Tap to rotate pieces
- Swipe left/right to move
- Swipe down for faster drop
- Use HOLD button to store a piece
- Use DROP button for instant placement

Enjoy playing Tetris!

