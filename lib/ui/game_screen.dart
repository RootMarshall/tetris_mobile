import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_controller.dart';
import '../constants.dart';
import '../services/high_score_service.dart';
import 'board_widget.dart';
import 'next_piece_widget.dart';
import 'hold_box_widget.dart';
import 'tetris_popup.dart';
import 'game_over_dialog.dart';
import 'pause_menu_dialog.dart';
import 'countdown_overlay.dart';
import 'menu_screen.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameController controller;
  late int initialSpeed;
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _dragStartTime = 0;
  bool _hasHardDropped = false;
  int highScore = 0;
  bool _showCountdown = true;
  bool _wasAutoPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Get speed based on difficulty
    switch (widget.difficulty) {
      case Difficulty.beginner:
        initialSpeed = difficultySpeed['beginner']!;
        break;
      case Difficulty.normal:
        initialSpeed = difficultySpeed['normal']!;
        break;
      case Difficulty.hard:
        initialSpeed = difficultySpeed['hard']!;
        break;
    }
    controller = GameController(initialSpeed: initialSpeed);
    controller.addListener(_onGameStateChanged);
    _loadHighScore();
    // Game will start after countdown completes
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause game when app is minimized or inactive
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!controller.state.isGameOver && !controller.state.isPaused && !_showCountdown) {
        controller.pauseGame();
        _wasAutoPaused = true; // Track that we auto-paused
      }
    }
    // Show pause menu when app resumes after auto-pause
    else if (state == AppLifecycleState.resumed) {
      if (_wasAutoPaused && mounted) {
        _wasAutoPaused = false;
        // Small delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && controller.state.isPaused) {
            _showPauseMenuWithoutToggle();
          }
        });
      }
    }
  }

  void _startGameWithCountdown() {
    setState(() {
      _showCountdown = true;
    });
  }

  void _onCountdownComplete() {
    setState(() {
      _showCountdown = false;
    });
    controller.startGame();
  }

  void _restartGame() {
    controller.dispose();
    controller = GameController(initialSpeed: initialSpeed);
    controller.addListener(_onGameStateChanged);
    _startGameWithCountdown();
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreService.getHighScore();
    setState(() {
      highScore = score;
    });
  }

  void _onGameStateChanged() {
    setState(() {});
    if (controller.state.isGameOver) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() async {
    final isNewHighScore = await HighScoreService.updateHighScore(controller.state.score);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => GameOverDialog(
            score: controller.state.score,
            level: controller.state.level,
            lines: controller.state.linesCleared,
            highScore: controller.state.score > highScore ? controller.state.score : highScore,
            isNewHighScore: isNewHighScore,
            onRestart: () {
              Navigator.of(context).pop(); // Close dialog
              _loadHighScore();
              _restartGame();
            },
            onMenu: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to menu screen
            },
          ),
        );
      }
    });
  }

  void _showPauseMenu() {
    controller.pauseGame(); // Pause the game
    _showPauseMenuWithoutToggle();
  }

  void _showPauseMenuWithoutToggle() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseMenuDialog(
        onResume: () {
          Navigator.of(context).pop(); // Close dialog
          controller.pauseGame(); // Resume game
        },
        onRestart: () {
          Navigator.of(context).pop(); // Close dialog
          _restartGame();
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_onGameStateChanged);
    controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _dragStartY = details.localPosition.dy;
    _dragStartTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    _hasHardDropped = false; // Reset flag for new gesture
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double deltaX = details.localPosition.dx - _dragStartX;
    double deltaY = details.localPosition.dy - _dragStartY;

    if (deltaX.abs() > 30) {
      if (deltaX > 0) {
        controller.moveRight();
      } else {
        controller.moveLeft();
      }
      _dragStartX = details.localPosition.dx;
    }

    if (deltaY > 35 && !_hasHardDropped) {
      // Check velocity for hard drop
      double currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
      double timeDelta = currentTime - _dragStartTime;
      double velocity = deltaY / (timeDelta + 1); // pixels per millisecond
      
      if (velocity > 1.2) { // Fast swipe = hard drop (lowered threshold for easier triggering)
        HapticFeedback.heavyImpact(); // Strong vibration for slam
        controller.hardDrop();
        _hasHardDropped = true; // Prevent multiple hard drops in one gesture
      } else {
        controller.moveDown();
        _dragStartY = details.localPosition.dy;
      }
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    controller.rotate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top info bar with pause button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard('SCORE', controller.state.score.toString()),
                      _buildHighScoreCard(highScore),
                      _buildInfoCard('LEVEL', controller.state.level.toString()),
                      _buildInfoCard('LINES', controller.state.linesCleared.toString()),
                      // Pause button in top right
                      GestureDetector(
                        onTap: _showPauseMenu,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: boardColor,
                            border: Border.all(color: gridColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.pause,
                            color: Colors.blue.shade400,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hold and Next boxes row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Hold box (tappable)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          controller.holdPiece();
                        },
                        child: HoldBoxWidget(
                          heldPiece: controller.state.heldPiece,
                          canHold: controller.state.canHold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Next piece
                      NextPieceWidget(
                        nextPiece: controller.state.nextPiece,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main game board - expanded to fill available space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: _handleTap,
                      onPanStart: _handleDragStart,
                      onPanUpdate: _handleDragUpdate,
                      child: BoardWidget(
                        board: controller.board,
                        currentPiece: controller.state.currentPiece,
                        showSlamEffect: controller.showSlamEffect,
                        rowsToClear: controller.rowsToClear,
                        clearAnimationProgress: controller.clearAnimationProgress,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),

            // TETRIS popup overlay
            if (controller.showTetrisPopup)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: TetrisPopup(),
                ),
              ),

            // Countdown overlay
            if (_showCountdown)
              CountdownOverlay(
                onComplete: _onCountdownComplete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: boardColor,
        border: Border.all(color: gridColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: boardColor,
        border: Border.all(color: Colors.amber.shade700, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade500, size: 12),
              const SizedBox(width: 4),
              Text(
                'BEST',
                style: TextStyle(
                  color: Colors.amber.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            score.toString(),
            style: TextStyle(
              color: Colors.amber.shade400,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

