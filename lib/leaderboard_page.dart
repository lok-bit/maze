import 'package:flutter/material.dart';
import 'leaderboard_manager.dart';
import 'package:provider/provider.dart';
import 'music_controller.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}
class _LeaderboardPageState extends State<LeaderboardPage> {
  MusicController? musicController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 延遲獲取 Provider，確保 context 可用
      musicController = Provider.of<MusicController>(context, listen: false);
      _playMusicWithLoop("1.mp3");
    });
  }

  void _playMusicWithLoop(String assetPath) {
    musicController?.playMusic(assetPath);
    musicController?.player.onPlayerComplete.listen((_) {
      musicController?.playMusic(assetPath); // 音樂結束後重播
    });
  }

  @override
  void dispose() {
    musicController?.stopMusic(); // 確保退出頁面時停止音樂
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> scores = LeaderboardManager.getTopScores();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '排行榜',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1),
        ),
      ),
      body: ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              '第 ${index + 1} 名',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1),
            ),
            trailing: Text(
              '${scores[index] / 1000} 秒',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1),
            ),
          );
        },
      ),
    );
  }
}


