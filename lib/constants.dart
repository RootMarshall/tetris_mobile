import 'package:flutter/material.dart';

// Game board dimensions
const int boardWidth = 10;
const int boardHeight = 20;

// Cell size for rendering
const double cellSize = 24.0;

// Game speed settings by difficulty
const Map<String, int> difficultySpeed = {
  'beginner': 800,  // Slower, more relaxed
  'normal': 600,    // Balanced
  'hard': 400,      // Fast and challenging
};
const double speedMultiplier = 0.9; // Speed increase per level

// Scoring
const Map<int, int> lineScores = {
  1: 40,
  2: 100,
  3: 300,
  4: 1200, // TETRIS
};

// Colors for each tetromino type
const Map<TetrominoType, Color> tetrominoColors = {
  TetrominoType.I: Color(0xFF00F0F0), // Cyan
  TetrominoType.O: Color(0xFFF0F000), // Yellow
  TetrominoType.T: Color(0xFFA000F0), // Purple
  TetrominoType.S: Color(0xFF00F000), // Green
  TetrominoType.Z: Color(0xFFF00000), // Red
  TetrominoType.J: Color(0xFF0000F0), // Blue
  TetrominoType.L: Color(0xFFF0A000), // Orange
};

// UI Colors
const Color backgroundColor = Color(0xFF1A1A2E);
const Color boardColor = Color(0xFF16213E);
const Color gridColor = Color(0xFF0F3460);
const Color emptyColor = Color(0xFF0F3460);
const Color textColor = Color(0xFFEAEAEA);

enum TetrominoType { I, O, T, S, Z, J, L }

