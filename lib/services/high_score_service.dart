import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const String _highScoreKey = 'tetris_high_score';
  
  // Get the current high score
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }
  
  // Update high score if new score is higher
  static Future<bool> updateHighScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = prefs.getInt(_highScoreKey) ?? 0;
    
    if (newScore > currentHighScore) {
      await prefs.setInt(_highScoreKey, newScore);
      return true; // New high score!
    }
    return false; // Not a new high score
  }
  
  // Clear high score (for testing or reset)
  static Future<void> clearHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoreKey);
  }
}

