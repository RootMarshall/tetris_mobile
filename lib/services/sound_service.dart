import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final Map<String, AudioPlayer> _players = {};
  AudioPlayer? _musicPlayer;
  bool _soundEnabled = true;
  bool _initialized = false;
  bool _isDisposing = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    
    _initialized = true;
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    
    // Stop music if sound is disabled
    if (!_soundEnabled) {
      await stopMusic();
    }
  }

  bool get isSoundEnabled => _soundEnabled;

  Future<void> playSound(String soundName) async {
    if (!_soundEnabled || _isDisposing) return;

    try {
      // Get or create player for this sound
      if (!_players.containsKey(soundName)) {
        _players[soundName] = AudioPlayer();
        // Set player to release mode for quick replays
        await _players[soundName]!.setReleaseMode(ReleaseMode.stop);
      }

      final player = _players[soundName]!;
      
      // For rapid-fire sounds, properly stop first then play
      // Wait a tiny bit to ensure clean restart
      await player.stop();
      await player.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
      // This allows the game to work without sound files
    }
  }

  // Background music (looping)
  Future<void> playMusic(String musicName) async {
    if (!_soundEnabled || _isDisposing) return;

    try {
      // Stop any currently playing music first and wait for it to complete
      await stopMusic();
      
      // Small delay to ensure previous player is fully disposed
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Create new music player
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.6);
      await _musicPlayer!.play(AssetSource('sounds/$musicName.mp3'));
    } catch (e) {
      // Silently fail if music file doesn't exist
      _musicPlayer = null;
    }
  }

  Future<void> stopMusic() async {
    if (_musicPlayer != null) {
      try {
        await _musicPlayer!.stop();
        await _musicPlayer!.dispose();
      } catch (e) {
        // Player might already be disposed
      } finally {
        _musicPlayer = null;
      }
    }
  }

  // Specific game sounds
  Future<void> playMove() => playSound('move');
  Future<void> playRotate() => playSound('rotate');
  Future<void> playLand() => playSound('land');
  Future<void> playClear() => playSound('clear');
  Future<void> playTetris() => playSound('tetris');
  Future<void> playGameOver() => playSound('game_over');
  Future<void> playHold() => playSound('hold');
  Future<void> playLevelUp() => playSound('level_up');
  Future<void> playCountdown() => playSound('countdown');
  
  // Background music
  Future<void> playIntroMusic() => playMusic('intro_music');

  // Stop all game sounds (but don't dispose the service since it's a singleton)
  Future<void> stopAllGameSounds() async {
    // Stop all sound effect players but keep them for reuse
    for (var player in _players.values) {
      try {
        await player.stop();
      } catch (e) {
        // Player might already be stopped
      }
    }
  }

  // Full cleanup - only call this when the app is closing
  Future<void> dispose() async {
    _isDisposing = true;
    
    // Stop and dispose music player
    await stopMusic();
    
    // Stop and dispose all sound effect players
    for (var player in _players.values) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        // Player might already be disposed
      }
    }
    _players.clear();
    
    _isDisposing = false;
    _initialized = false;
  }
}

