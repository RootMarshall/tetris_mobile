import 'package:flutter/material.dart';
import '../constants.dart';

class GameBoard {
  late List<List<Color?>> grid;

  GameBoard() {
    grid = List.generate(
      boardHeight,
      (_) => List.generate(boardWidth, (_) => null),
    );
  }

  bool isOccupied(int x, int y) {
    if (x < 0 || x >= boardWidth || y < 0 || y >= boardHeight) {
      return true;
    }
    return grid[y][x] != null;
  }

  void placePiece(List<List<int>> shape, int pieceX, int pieceY, Color color) {
    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          int boardX = pieceX + col;
          int boardY = pieceY + row;
          if (boardY >= 0 && boardY < boardHeight && boardX >= 0 && boardX < boardWidth) {
            grid[boardY][boardX] = color;
          }
        }
      }
    }
  }

  List<int> getFullRows() {
    List<int> fullRows = [];
    for (int row = 0; row < boardHeight; row++) {
      bool isFull = true;
      for (int col = 0; col < boardWidth; col++) {
        if (grid[row][col] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        fullRows.add(row);
      }
    }
    return fullRows;
  }

  void clearRows(List<int> rows) {
    // Sort rows in descending order to avoid index shifting issues
    List<int> sortedRows = List.from(rows)..sort((a, b) => b.compareTo(a));
    
    // Remove each full row from bottom to top
    for (int row in sortedRows) {
      grid.removeAt(row);
    }
    
    // Add empty rows at the top
    for (int i = 0; i < sortedRows.length; i++) {
      grid.insert(0, List.generate(boardWidth, (_) => null));
    }
  }

  void reset() {
    grid = List.generate(
      boardHeight,
      (_) => List.generate(boardWidth, (_) => null),
    );
  }
}

