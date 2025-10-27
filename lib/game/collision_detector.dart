import '../models/tetromino.dart';
import '../models/game_board.dart';

class CollisionDetector {
  static bool checkCollision(Tetromino piece, GameBoard board, {int offsetX = 0, int offsetY = 0}) {
    List<List<int>> shape = piece.shape;
    int pieceX = piece.x + offsetX;
    int pieceY = piece.y + offsetY;

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          int boardX = pieceX + col;
          int boardY = pieceY + row;
          
          if (board.isOccupied(boardX, boardY)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool canRotate(Tetromino piece, GameBoard board) {
    piece.rotate();
    bool collision = checkCollision(piece, board);
    piece.rotateBack();
    return !collision;
  }

  static int calculateGhostY(Tetromino piece, GameBoard board) {
    int ghostY = piece.y;
    while (!checkCollision(piece, board, offsetY: ghostY - piece.y + 1)) {
      ghostY++;
    }
    return ghostY;
  }
}

