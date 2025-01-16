class LeaderboardManager {
  static List<int> _scores = [];

  static void addScore(int score) {
    _scores.add(score);
    _scores.sort();
    if (_scores.length > 10) {
      _scores = _scores.sublist(0, 10); // 只保留前十名
    }
  }

  static List<int> getTopScores() {
    return List.unmodifiable(_scores); // 返回不可修改的副本
  }
}
