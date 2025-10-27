import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import '../constants.dart';

class HoldBoxWidget extends StatelessWidget {
  final Tetromino? heldPiece;
  final bool canHold;

  const HoldBoxWidget({
    Key? key,
    this.heldPiece,
    required this.canHold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: boardColor,
        border: Border.all(
          color: canHold ? gridColor : Colors.grey.shade700,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'HOLD',
            style: TextStyle(
              color: canHold ? textColor : Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            height: 50,
            child: heldPiece != null
                ? Opacity(
                    opacity: canHold ? 1.0 : 0.5,
                    child: CustomPaint(
                      painter: HeldPiecePainter(piece: heldPiece!),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class HeldPiecePainter extends CustomPainter {
  final Tetromino piece;

  HeldPiecePainter({required this.piece});

  @override
  void paint(Canvas canvas, Size size) {
    final shape = piece.shape;
    final color = tetrominoColors[piece.type]!;
    
    // Calculate piece dimensions
    int maxCols = shape[0].length;
    int maxRows = shape.length;
    
    // Calculate cell size to fit the piece
    double cellSize = (size.width / maxCols).clamp(0, 20);
    
    // Center the piece
    double offsetX = (size.width - (maxCols * cellSize)) / 2;
    double offsetY = (size.height - (maxRows * cellSize)) / 2;

    final paint = Paint()..color = color;

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              offsetX + col * cellSize + 1,
              offsetY + row * cellSize + 1,
              cellSize - 2,
              cellSize - 2,
            ),
            const Radius.circular(2),
          );
          canvas.drawRRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(HeldPiecePainter oldDelegate) => true;
}

