import '../constants.dart';

class Tetromino {
  final TetrominoType type;
  final List<List<List<int>>> rotations;
  int currentRotation;
  int x;
  int y;

  Tetromino({
    required this.type,
    required this.rotations,
    this.currentRotation = 0,
    this.x = 3,
    this.y = 0,
  });

  List<List<int>> get shape => rotations[currentRotation];

  void rotate() {
    currentRotation = (currentRotation + 1) % rotations.length;
  }

  void rotateBack() {
    currentRotation = (currentRotation - 1) % rotations.length;
    if (currentRotation < 0) currentRotation = rotations.length - 1;
  }

  Tetromino copy() {
    return Tetromino(
      type: type,
      rotations: rotations,
      currentRotation: currentRotation,
      x: x,
      y: y,
    );
  }

  static Tetromino create(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return Tetromino(
          type: type,
          rotations: [
            [
              [0, 0, 0, 0],
              [1, 1, 1, 1],
              [0, 0, 0, 0],
              [0, 0, 0, 0],
            ],
            [
              [0, 0, 1, 0],
              [0, 0, 1, 0],
              [0, 0, 1, 0],
              [0, 0, 1, 0],
            ],
          ],
        );
      case TetrominoType.O:
        return Tetromino(
          type: type,
          rotations: [
            [
              [1, 1],
              [1, 1],
            ],
          ],
        );
      case TetrominoType.T:
        return Tetromino(
          type: type,
          rotations: [
            [
              [0, 1, 0],
              [1, 1, 1],
              [0, 0, 0],
            ],
            [
              [0, 1, 0],
              [0, 1, 1],
              [0, 1, 0],
            ],
            [
              [0, 0, 0],
              [1, 1, 1],
              [0, 1, 0],
            ],
            [
              [0, 1, 0],
              [1, 1, 0],
              [0, 1, 0],
            ],
          ],
        );
      case TetrominoType.S:
        return Tetromino(
          type: type,
          rotations: [
            [
              [0, 1, 1],
              [1, 1, 0],
              [0, 0, 0],
            ],
            [
              [0, 1, 0],
              [0, 1, 1],
              [0, 0, 1],
            ],
          ],
        );
      case TetrominoType.Z:
        return Tetromino(
          type: type,
          rotations: [
            [
              [1, 1, 0],
              [0, 1, 1],
              [0, 0, 0],
            ],
            [
              [0, 0, 1],
              [0, 1, 1],
              [0, 1, 0],
            ],
          ],
        );
      case TetrominoType.J:
        return Tetromino(
          type: type,
          rotations: [
            [
              [1, 0, 0],
              [1, 1, 1],
              [0, 0, 0],
            ],
            [
              [0, 1, 1],
              [0, 1, 0],
              [0, 1, 0],
            ],
            [
              [0, 0, 0],
              [1, 1, 1],
              [0, 0, 1],
            ],
            [
              [0, 1, 0],
              [0, 1, 0],
              [1, 1, 0],
            ],
          ],
        );
      case TetrominoType.L:
        return Tetromino(
          type: type,
          rotations: [
            [
              [0, 0, 1],
              [1, 1, 1],
              [0, 0, 0],
            ],
            [
              [0, 1, 0],
              [0, 1, 0],
              [0, 1, 1],
            ],
            [
              [0, 0, 0],
              [1, 1, 1],
              [1, 0, 0],
            ],
            [
              [1, 1, 0],
              [0, 1, 0],
              [0, 1, 0],
            ],
          ],
        );
    }
  }

  static TetrominoType random() {
    return TetrominoType.values[
        DateTime.now().millisecondsSinceEpoch % TetrominoType.values.length];
  }
}

