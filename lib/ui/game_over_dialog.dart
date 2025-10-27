import 'package:flutter/material.dart';
import '../constants.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int level;
  final int lines;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;

  const GameOverDialog({
    Key? key,
    required this.score,
    required this.level,
    required this.lines,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: boardColor,
          border: Border.all(
            color: isNewHighScore ? Colors.amber.shade600 : gridColor,
            width: isNewHighScore ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isNewHighScore ? [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNewHighScore ? 'NEW HIGH SCORE!' : 'GAME OVER',
              style: TextStyle(
                color: isNewHighScore ? Colors.amber.shade400 : textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isNewHighScore) ...[
              const SizedBox(height: 8),
              Icon(Icons.emoji_events, color: Colors.amber.shade400, size: 40),
            ],
            const SizedBox(height: 24),
            _buildStatRow('Score', score.toString()),
            const SizedBox(height: 12),
            _buildStatRow('High Score', highScore.toString(), isHighlight: true),
            const SizedBox(height: 12),
            _buildStatRow('Level', level.toString()),
            const SizedBox(height: 12),
            _buildStatRow('Lines', lines.toString()),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Pop game screen to return to menu
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'MENU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRestart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: isHighlight ? Colors.amber.shade400 : textColor,
            fontSize: 18,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? Colors.amber.shade300 : textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

