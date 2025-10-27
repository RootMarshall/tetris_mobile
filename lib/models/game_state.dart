import 'dart:math';
import '../constants.dart';
import 'tetromino.dart';

class GameState {
  int score;
  int level;
  int linesCleared;
  Tetromino? currentPiece;
  Tetromino? nextPiece;
  Tetromino? heldPiece;
  bool canHold;
  bool isGameOver;
  bool isPaused;

  GameState({
    this.score = 0,
    this.level = 1,
    this.linesCleared = 0,
    this.currentPiece,
    this.nextPiece,
    this.heldPiece,
    this.canHold = true,
    this.isGameOver = false,
    this.isPaused = false,
  });

  void addScore(int lines) {
    if (lineScores.containsKey(lines)) {
      score += lineScores[lines]! * level;
    }
  }

  void addLines(int lines) {
    linesCleared += lines;
    level = (linesCleared ~/ 10) + 1;
  }

  void reset() {
    score = 0;
    level = 1;
    linesCleared = 0;
    currentPiece = null;
    nextPiece = null;
    heldPiece = null;
    canHold = true;
    isGameOver = false;
    isPaused = false;
  }

  int getCurrentSpeed(int initialSpeed) {
    // Speed decreases by speedMultiplier each level
    // Level 1: initialSpeed, Level 2: initialSpeed * 0.9, etc.
    double speed = initialSpeed * pow(speedMultiplier, level - 1).toDouble();
    return speed.round().clamp(100, initialSpeed);
  }
}

