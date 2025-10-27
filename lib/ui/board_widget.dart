import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../models/tetromino.dart';
import '../constants.dart';
import '../game/collision_detector.dart';

class BoardWidget extends StatelessWidget {
  final GameBoard board;
  final Tetromino? currentPiece;
  final bool showSlamEffect;
  final List<int> rowsToClear;
  final double clearAnimationProgress;

  const BoardWidget({
    Key? key,
    required this.board,
    this.currentPiece,
    this.showSlamEffect = false,
    this.rowsToClear = const [],
    this.clearAnimationProgress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: showSlamEffect 
          ? (Matrix4.identity()..scale(1.02, 0.98)) 
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: boardColor,
        border: Border.all(
          color: showSlamEffect ? Colors.white.withOpacity(0.3) : gridColor,
          width: showSlamEffect ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: showSlamEffect ? [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: AspectRatio(
        aspectRatio: boardWidth / boardHeight,
        child: CustomPaint(
          painter: BoardPainter(
            board: board,
            currentPiece: currentPiece,
            rowsToClear: rowsToClear,
            clearAnimationProgress: clearAnimationProgress,
          ),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final GameBoard board;
  final Tetromino? currentPiece;
  final List<int> rowsToClear;
  final double clearAnimationProgress;

  BoardPainter({
    required this.board,
    this.currentPiece,
    this.rowsToClear = const [],
    this.clearAnimationProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / boardWidth;
    final cellHeight = size.height / boardHeight;
    final paint = Paint();

    // Draw grid
    paint.color = gridColor;
    paint.strokeWidth = 0.5;
    for (int i = 0; i <= boardWidth; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }
    for (int i = 0; i <= boardHeight; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }

    // Draw placed pieces with pop animation for clearing rows
    for (int row = 0; row < boardHeight; row++) {
      bool isClearing = rowsToClear.contains(row);
      
      for (int col = 0; col < boardWidth; col++) {
        if (board.grid[row][col] != null) {
          if (isClearing) {
            // Animated clearing effect - scale and fade
            _drawClearingCell(
              canvas,
              col * cellWidth,
              row * cellHeight,
              cellWidth,
              cellHeight,
              board.grid[row][col]!,
            );
          } else {
            _drawCell(
              canvas,
              col * cellWidth,
              row * cellHeight,
              cellWidth,
              cellHeight,
              board.grid[row][col]!,
            );
          }
        }
      }
    }

    // Draw ghost piece (translucent outline showing where piece will land)
    if (currentPiece != null) {
      final ghostY = CollisionDetector.calculateGhostY(currentPiece!, board);
      
      // Only draw ghost if it's below the current piece
      if (ghostY > currentPiece!.y) {
        final shape = currentPiece!.shape;
        final color = tetrominoColors[currentPiece!.type]!;
        
        for (int row = 0; row < shape.length; row++) {
          for (int col = 0; col < shape[row].length; col++) {
            if (shape[row][col] == 1) {
              int boardX = currentPiece!.x + col;
              int boardY = ghostY + row;
              if (boardY >= 0) {
                _drawGhostCell(
                  canvas,
                  boardX * cellWidth,
                  boardY * cellHeight,
                  cellWidth,
                  cellHeight,
                  color,
                );
              }
            }
          }
        }
      }
    }

    // Draw current piece
    if (currentPiece != null) {
      final shape = currentPiece!.shape;
      final color = tetrominoColors[currentPiece!.type]!;
      
      for (int row = 0; row < shape.length; row++) {
        for (int col = 0; col < shape[row].length; col++) {
          if (shape[row][col] == 1) {
            int boardX = currentPiece!.x + col;
            int boardY = currentPiece!.y + row;
            if (boardY >= 0) {
              _drawCell(
                canvas,
                boardX * cellWidth,
                boardY * cellHeight,
                cellWidth,
                cellHeight,
                color,
              );
            }
          }
        }
      }
    }
  }

  void _drawCell(Canvas canvas, double x, double y, double width, double height, Color color) {
    final paint = Paint()..color = color;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + 1, y + 1, width - 2, height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    // Add highlight for 3D effect
    final highlightPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x + 2, y + 2),
      Offset(x + width - 2, y + 2),
      highlightPaint,
    );
    canvas.drawLine(
      Offset(x + 2, y + 2),
      Offset(x + 2, y + height - 2),
      highlightPaint,
    );
  }

  void _drawGhostCell(Canvas canvas, double x, double y, double width, double height, Color color) {
    // Draw translucent outline only
    final outlinePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + 2, y + 2, width - 4, height - 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, outlinePaint);
  }

  void _drawClearingCell(Canvas canvas, double x, double y, double width, double height, Color color) {
    // Crumbling/exploding animation with particles
    final progress = clearAnimationProgress;
    
    if (progress < 0.3) {
      // Phase 1: Flash and expand (0.0 - 0.3)
      final flashProgress = progress / 0.3;
      final scale = 1.0 + (flashProgress * 0.3);
      final inset = (width * (1 - scale)) / 2;
      
      final paint = Paint()
        ..color = Color.lerp(color, Colors.white, flashProgress)!.withOpacity(1.0 - flashProgress * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 1 - inset,
          y + 1 - inset,
          (width - 2) * scale,
          (height - 2) * scale,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    } else {
      // Phase 2: Break into particles and scatter (0.3 - 1.0)
      final crumbleProgress = (progress - 0.3) / 0.7;
      
      // Draw multiple particle fragments
      for (int i = 0; i < 9; i++) {
        final row = i ~/ 3;
        final col = i % 3;
        final particleSize = width / 3.5;
        
        // Calculate particle offset (scatter effect)
        final scatterX = (col - 1) * crumbleProgress * width * 0.8;
        final scatterY = (row - 1) * crumbleProgress * height * 0.6 + (crumbleProgress * crumbleProgress * 30); // Gravity
        final rotation = crumbleProgress * (i * 0.5 - 1.5);
        
        final particleX = x + width / 2 + scatterX + (col - 1) * particleSize;
        final particleY = y + height / 2 + scatterY + (row - 1) * particleSize;
        
        canvas.save();
        canvas.translate(particleX, particleY);
        canvas.rotate(rotation);
        
        final paint = Paint()
          ..color = color.withOpacity((1.0 - crumbleProgress) * 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, crumbleProgress * 2);
        
        final particleRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize * (1.0 - crumbleProgress * 0.5),
            height: particleSize * (1.0 - crumbleProgress * 0.5),
          ),
          Radius.circular(2 * (1.0 - crumbleProgress)),
        );
        
        canvas.drawRRect(particleRect, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => true;
}

