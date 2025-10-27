import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/high_score_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';

enum Difficulty { beginner, normal, hard }

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  Difficulty selectedDifficulty = Difficulty.normal;
  int highScore = 0;
  final SoundService soundService = SoundService();
  bool soundEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHighScore();
    _loadSoundSetting();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Only handle lifecycle events if this screen is currently visible
    // Check if we're the top route in the navigation stack
    if (!mounted) return;
    
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    
    // Pause intro music when app is minimized or inactive
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      soundService.stopMusic().catchError((_) {});
    }
    // Resume intro music when app comes back (only if we're the active screen)
    else if (state == AppLifecycleState.resumed) {
      if (soundEnabled) {
        soundService.playIntroMusic();
      }
    }
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreService.getHighScore();
    setState(() {
      highScore = score;
    });
  }

  Future<void> _loadSoundSetting() async {
    await soundService.initialize();
    setState(() {
      soundEnabled = soundService.isSoundEnabled;
    });
    
    // Start playing intro music
    if (soundEnabled) {
      soundService.playIntroMusic();
    }
  }

  Future<void> _toggleSound() async {
    await soundService.toggleSound();
    setState(() {
      soundEnabled = soundService.isSoundEnabled;
    });
    
    // Start or stop intro music based on new setting
    if (soundEnabled) {
      soundService.playIntroMusic();
    } else {
      soundService.stopMusic();
    }
  }

  void _startGame() async {
    // Stop intro music when starting game
    soundService.stopMusic();
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: selectedDifficulty),
      ),
    );
    
    // Reload high score when returning from game
    _loadHighScore();
    
    // Restart intro music when returning to menu
    if (soundEnabled) {
      soundService.playIntroMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop music when menu is disposed
    soundService.stopMusic().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Sound toggle button at top right
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: _toggleSound,
                icon: Icon(
                  soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: soundEnabled ? Colors.cyan.shade400 : Colors.grey.shade600,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: boardColor,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              // Title - TETRISN'T
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                  ),
                  children: [
                    const TextSpan(
                      text: 'TETR',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    TextSpan(
                      text: 'ISN\'T',
                      style: TextStyle(
                        color: Colors.red.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // High Score display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: boardColor,
                  border: Border.all(color: Colors.amber.shade600, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber.shade400, size: 24),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HIGH SCORE',
                          style: TextStyle(
                            color: Colors.amber.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          highScore.toString(),
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Difficulty selection
              const Text(
                'SELECT DIFFICULTY',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              // Beginner button
              _buildDifficultyButton(
                difficulty: Difficulty.beginner,
                label: 'BEGINNER',
                description: 'Relaxed pace',
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 16),

              // Normal button
              _buildDifficultyButton(
                difficulty: Difficulty.normal,
                label: 'NORMAL',
                description: 'Balanced speed',
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 16),

              // Hard button
              _buildDifficultyButton(
                difficulty: Difficulty.hard,
                label: 'HARD',
                description: 'Fast challenge',
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 48),

              // Start button
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
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

  Widget _buildDifficultyButton({
    required Difficulty difficulty,
    required String label,
    required String description,
    required Color color,
  }) {
    final isSelected = selectedDifficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : boardColor,
          border: Border.all(
            color: isSelected ? color : gridColor,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? color.withOpacity(0.8) : textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

