import 'dart:math';
import 'package:flutter/material.dart';
import 'maze_page.dart';
import 'leaderboard_page.dart';
import 'package:provider/provider.dart';
import 'music_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicController()), // 註冊 MusicController
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze Game',
      home: MainPage(),
      routes: {
        '/maze': (context) => MazePage(),
        '/leaderboard': (context) => LeaderboardPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MusicController? musicController;
  final Random _random = Random();
  List<List<int>> _randomMaze = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      musicController = Provider.of<MusicController>(context, listen: false);
      _playMusicWithLoop("2.mp3");
    });
    _generateRandomMaze(20, 10); // 生成20行10列的隨機格子
  }

  void _generateRandomMaze(int rows, int cols) {
    setState(() {
      _randomMaze = List.generate(
        rows,
            (_) => List.generate(cols, (_) => _random.nextBool() ? 1 : 0),
      );
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
    musicController?.stopMusic(); // 確保退出页面時停止音樂
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 獲取按鈕位置，用於淡化處理
    Size screenSize = MediaQuery.of(context).size;
    double buttonWidth = screenSize.width * 0.5;
    double buttonHeight = 40.0; // 假設按鈕高度
    double centerX = screenSize.width / 2;
    double centerY = screenSize.height / 2;

    return Scaffold(
      appBar: AppBar(title: Text('Maze Game')),
      body: Stack(
        children: [
          // 隨機生成迷宮背景
          CustomPaint(
            size: screenSize,
            painter: RandomMazePainter(
              maze: _randomMaze,
              centerX: centerX,
              centerY: centerY,
              buttonWidth: buttonWidth,
              buttonHeight: buttonHeight,
            ),
          ),
          // 主內容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/maze');
                    },
                    child: Text('開始遊戲',
                        style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.width * 0.1))),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/leaderboard');
                  },
                  child: Text('排行榜',
                      style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width * 0.1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RandomMazePainter extends CustomPainter {
  final List<List<int>> maze;
  final double centerX; // 主頁面中心X位置
  final double centerY; // 主頁面中心Y位置
  final double buttonWidth;
  final double buttonHeight;

  RandomMazePainter({
    required this.maze,
    required this.centerX,
    required this.centerY,
    required this.buttonWidth,
    required this.buttonHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cellWidth = size.width / maze[0].length;
    double cellHeight = size.height / maze.length;

    Paint wallPaint = Paint()..color = Colors.black;
    Paint roadPaint = Paint()..color = Colors.white;
    Paint fadedPaint = Paint()..color = Colors.grey.withOpacity(0.5); // 淡化顏色

    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        Rect cell = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        // 檢查格子是否在按鈕周圍
        double cellCenterX = x * cellWidth + cellWidth / 2;
        double cellCenterY = y * cellHeight + cellHeight / 2;

        bool isNearButton = (cellCenterX > centerX - buttonWidth / 2 &&
            cellCenterX < centerX + buttonWidth / 2 &&
            cellCenterY > centerY - buttonHeight - 100 &&
            cellCenterY < centerY + buttonHeight +20 );

        if (maze[y][x] == 1) {
          canvas.drawRect(cell, isNearButton ? fadedPaint : wallPaint); // 黑色或淡化
        } else {
          canvas.drawRect(cell, roadPaint); // 白色
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




