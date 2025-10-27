import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import '../models/game_board.dart';
import '../models/game_state.dart';
import '../constants.dart';
import 'collision_detector.dart';

class GameController extends ChangeNotifier {
  final GameBoard board = GameBoard();
  final GameState state = GameState();
  final int initialSpeed;
  Timer? gameTimer;
  bool showTetrisPopup = false;
  bool showSlamEffect = false;
  List<int> rowsToClear = [];
  double clearAnimationProgress = 0.0;
  bool _isProcessingLock = false;

  GameController({required this.initialSpeed}) {
    _initGame();
  }

  void _initGame() {
    state.nextPiece = _generateRandomPiece();
    _spawnNewPiece();
  }

  Tetromino _generateRandomPiece() {
    final random = Random();
    final type = TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    return Tetromino.create(type);
  }

  void _spawnNewPiece() {
    // Prevent spawning if we're already processing a lock/spawn
    if (_isProcessingLock) return;
    
    state.currentPiece = state.nextPiece;
    state.nextPiece = _generateRandomPiece();
    state.canHold = true;

    if (state.currentPiece != null && 
        CollisionDetector.checkCollision(state.currentPiece!, board)) {
      state.isGameOver = true;
      gameTimer?.cancel();
    }
    notifyListeners();
  }

  void startGame() {
    state.reset();
    board.reset();
    _initGame();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      Duration(milliseconds: state.getCurrentSpeed(initialSpeed)),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (state.isPaused || state.isGameOver) return;
    moveDown();
  }

  void moveLeft() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    if (!CollisionDetector.checkCollision(state.currentPiece!, board, offsetX: -1)) {
      state.currentPiece!.x--;
      
      // Reset lock delay if piece is grounded
      if (CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
        _resetLockDelay();
      }
      
      notifyListeners();
    }
  }

  void moveRight() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    if (!CollisionDetector.checkCollision(state.currentPiece!, board, offsetX: 1)) {
      state.currentPiece!.x++;
      
      // Reset lock delay if piece is grounded
      if (CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
        _resetLockDelay();
      }
      
      notifyListeners();
    }
  }

  Timer? _lockDelayTimer;
  int _lockDelayCount = 0;
  bool _isLockDelayActive = false;
  static const int maxLockDelayMoves = 15; // Max moves before forced lock
  static const int lockDelayMs = 500; // Half second to adjust

  void moveDown() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    if (!CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
      state.currentPiece!.y++;
      notifyListeners();
    } else {
      // Only start lock delay if not already active
      if (!_isLockDelayActive) {
        _startLockDelay();
      }
    }
  }
  
  void _startLockDelay() {
    _isLockDelayActive = true;
    _lockDelayTimer?.cancel();
    
    // Start new delay timer
    _lockDelayTimer = Timer(Duration(milliseconds: lockDelayMs), () {
      _lockPiece();
      _lockDelayCount = 0;
      _isLockDelayActive = false;
    });
  }
  
  void _resetLockDelay() {
    if (_lockDelayCount < maxLockDelayMoves && _isLockDelayActive) {
      _lockDelayCount++;
      _lockDelayTimer?.cancel();
      _startLockDelay();
    }
  }

  void hardDrop() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    // Cancel any pending lock delay
    _lockDelayTimer?.cancel();
    _isLockDelayActive = false;
    _lockDelayCount = 0;
    
    while (!CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
      state.currentPiece!.y++;
    }
    
    // Show slam effect
    showSlamEffect = true;
    notifyListeners();
    
    Timer(const Duration(milliseconds: 100), () {
      showSlamEffect = false;
      notifyListeners();
    });
    
    _lockPiece();
  }

  void rotate() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    if (CollisionDetector.canRotate(state.currentPiece!, board)) {
      state.currentPiece!.rotate();
      
      // Reset lock delay if piece is grounded
      if (CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
        _resetLockDelay();
      }
      
      notifyListeners();
    }
  }

  void holdPiece() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || !state.canHold || _isProcessingLock) {
      return;
    }

    if (state.heldPiece == null) {
      // First time holding
      state.heldPiece = Tetromino.create(state.currentPiece!.type);
      _spawnNewPiece();
    } else {
      // Swap current and held piece
      TetrominoType tempType = state.currentPiece!.type;
      state.currentPiece = Tetromino.create(state.heldPiece!.type);
      state.heldPiece = Tetromino.create(tempType);
    }
    
    state.canHold = false;
    notifyListeners();
  }

  void _lockPiece() {
    if (state.currentPiece == null || _isProcessingLock) return;
    
    // Set flag to prevent multiple simultaneous locks
    _isProcessingLock = true;

    Color color = tetrominoColors[state.currentPiece!.type]!;
    board.placePiece(
      state.currentPiece!.shape,
      state.currentPiece!.x,
      state.currentPiece!.y,
      color,
    );

    // Clear current piece immediately so game loop can't interact with it
    state.currentPiece = null;
    notifyListeners();

    List<int> fullRows = board.getFullRows();
    if (fullRows.isNotEmpty) {
      int linesCleared = fullRows.length;
      
      // Show rows clearing animation with progress
      rowsToClear = fullRows;
      clearAnimationProgress = 0.0;
      notifyListeners();
      
      // Animate the clearing over 400ms
      const totalDuration = 400;
      const steps = 20;
      const stepDuration = totalDuration ~/ steps;
      
      int currentStep = 0;
      Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
        currentStep++;
        clearAnimationProgress = currentStep / steps;
        notifyListeners();
        
        if (currentStep >= steps) {
          timer.cancel();
          
          // Actually clear the rows
          board.clearRows(fullRows);
          rowsToClear = [];
          clearAnimationProgress = 0.0;
          state.addLines(linesCleared);
          state.addScore(linesCleared);
          _startTimer();
          notifyListeners();
          
          _isProcessingLock = false; // Release lock before spawning
          _spawnNewPiece();
        }
      });
      
      // Show TETRIS popup if 4 lines cleared
      if (linesCleared == 4) {
        showTetrisPopup = true;
        notifyListeners();
        
        // Hide popup
        Timer(const Duration(milliseconds: 1500), () {
          showTetrisPopup = false;
          notifyListeners();
        });
      }
      
      return; // Don't spawn new piece yet
    }

    _isProcessingLock = false; // Release lock before spawning
    _spawnNewPiece();
  }

  void pauseGame() {
    state.isPaused = !state.isPaused;
    notifyListeners();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _lockDelayTimer?.cancel();
    super.dispose();
  }
}

