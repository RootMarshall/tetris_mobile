import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import '../models/game_board.dart';
import '../models/game_state.dart';
import '../constants.dart';
import 'collision_detector.dart';
import '../services/sound_service.dart';

class GameController extends ChangeNotifier {
  final GameBoard board = GameBoard();
  final GameState state = GameState();
  final int initialSpeed;
  final SoundService soundService = SoundService();
  Timer? gameTimer;
  bool showTetrisPopup = false;
  bool showSlamEffect = false;
  List<int> rowsToClear = [];
  double clearAnimationProgress = 0.0;
  bool _isProcessingLock = false;

  GameController({required this.initialSpeed}) {
    _initGame();
    soundService.initialize();
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

    // Activate spawn grace period to give player time to move the piece
    _isSpawnGraceActive = true;
    Timer(Duration(milliseconds: spawnGraceMs), () {
      _isSpawnGraceActive = false;
    });

    if (state.currentPiece != null && 
        CollisionDetector.checkCollision(state.currentPiece!, board)) {
      // Only end game if piece can't move left or right during grace period
      if (!_canMoveHorizontally()) {
        state.isGameOver = true;
        gameTimer?.cancel();
        soundService.playGameOver();
      }
    }
    notifyListeners();
  }

  bool _canMoveHorizontally() {
    if (state.currentPiece == null) return false;
    
    // Check if piece can move left or right
    bool canMoveLeft = !CollisionDetector.checkCollision(state.currentPiece!, board, offsetX: -1);
    bool canMoveRight = !CollisionDetector.checkCollision(state.currentPiece!, board, offsetX: 1);
    
    return canMoveLeft || canMoveRight;
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
      soundService.playMove();
      
      // End spawn grace period when player moves
      _isSpawnGraceActive = false;
      
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
      soundService.playMove();
      
      // End spawn grace period when player moves
      _isSpawnGraceActive = false;
      
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
  
  // Spawn grace period to prevent immediate game over
  bool _isSpawnGraceActive = false;
  static const int spawnGraceMs = 1000; // 1 second grace period

  void moveDown() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused || _isProcessingLock) return;
    
    if (!CollisionDetector.checkCollision(state.currentPiece!, board, offsetY: 1)) {
      state.currentPiece!.y++;
      notifyListeners();
    } else {
      // Don't lock during spawn grace period
      if (!_isSpawnGraceActive) {
        // Only start lock delay if not already active
        if (!_isLockDelayActive) {
          _startLockDelay();
        }
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
    
    soundService.playLand();
    
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
    
    // Try rotation with wall kick
    int wallKickOffset = CollisionDetector.tryRotateWithWallKick(state.currentPiece!, board);
    
    if (wallKickOffset != 999) { // 999 indicates failure
      state.currentPiece!.rotate();
      state.currentPiece!.x += wallKickOffset;
      soundService.playRotate();
      
      // End spawn grace period when player rotates
      _isSpawnGraceActive = false;
      
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

    soundService.playHold();

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
      
      // Play appropriate sound
      if (linesCleared == 4) {
        soundService.playTetris();
      } else {
        soundService.playClear();
      }
      
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
          bool leveledUp = state.addLines(linesCleared);
          state.addScore(linesCleared);
          
          // Play level up sound if level increased
          if (leveledUp) {
            soundService.playLevelUp();
          }
          
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

    // No lines cleared, just play land sound
    soundService.playLand();

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
    // Stop all game sounds when controller is disposed
    // Don't dispose the singleton service, just stop active sounds
    soundService.stopAllGameSounds().catchError((_) {});
    super.dispose();
  }
}

