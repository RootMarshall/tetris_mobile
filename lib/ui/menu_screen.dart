import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/high_score_service.dart';
import 'game_screen.dart';

enum Difficulty { beginner, normal, hard }

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Difficulty selectedDifficulty = Difficulty.normal;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreService.getHighScore();
    setState(() {
      highScore = score;
    });
  }

  void _startGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: selectedDifficulty),
      ),
    );
    // Reload high score when returning from game
    _loadHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'TETRIS',
                style: TextStyle(
                  color: textColor,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
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

