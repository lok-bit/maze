import 'package:flutter/material.dart';
import 'dart:math';
import 'leaderboard_manager.dart';
import 'music_controller.dart';
import 'package:provider/provider.dart';

class MazePage extends StatefulWidget {
  final int size = 51; // 迷宮的總大小（必須為奇數以確保有邊界）

  @override
  _MazePageState createState() => _MazePageState();
}

class _MazePageState extends State<MazePage> {
  late List<List<int>> maze;
  late int playerX;
  late int playerY;
  late Stopwatch stopwatch;
  final double viewRadius = 12; // 圓形視野的半徑

  MusicController? musicController;
  @override
  void initState() {
    super.initState();
    maze = generateCircularMaze(widget.size);

    // 初始化玩家位置
    playerX = widget.size ~/ 2;
    playerY = widget.size ~/ 2;
    // 開始計時
    stopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 延遲獲取 Provider，確保 context 可用
      musicController = Provider.of<MusicController>(context, listen: false);
      _playMusicWithLoop("3.mp3");
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
    // 計算單格大小
    double cellSize = MediaQuery.of(context).size.width / (viewRadius * 2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Circular Maze Game'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          // 根據手勢方向移動玩家
          if (details.delta.dx.abs() > details.delta.dy.abs()) {
            if (details.delta.dx > 0) {
              movePlayer(1, 0); // 右
            } else {
              movePlayer(-1, 0); // 左
            }
          } else {
            if (details.delta.dy > 0) {
              movePlayer(0, 1); // 下
            } else {
              movePlayer(0, -1); // 上
            }
          }
        },
        child: CustomPaint(
          size: MediaQuery.of(context).size,
          painter: MazePainter(
            maze: maze,
            playerX: playerX,
            playerY: playerY,
            cellSize: cellSize,
            viewRadius: viewRadius,
          ),
        ),
      ),
    );
  }


  void movePlayer(int dx, int dy) {
    int newX = playerX + dx;
    int newY = playerY + dy;

    // 確保玩家只能在道路（0）、終點（3）上移動
    if (maze[newY][newX] == 0 || maze[newY][newX] == 3) {
      setState(() {
        playerX = newX;
        playerY = newY;

        // 如果到達終點
        if (maze[newY][newX] == 3) {
          stopwatch.stop();
          showEndGameDialog(stopwatch.elapsedMilliseconds);

        }
      });
    }
  }
  void showEndGameDialog(int time) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('遊戲結束！',style:TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1)),
            content: Text('完成時間：${time / 1000} 秒',style:TextStyle(fontSize:20.0)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('返回主畫面',style:TextStyle(fontSize:16.0)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MazePage()),
                  );
                },
                child: Text('再來一場',style:TextStyle(fontSize:16.0)),
              ),
            ],
          );
        },
    );
    // 更新排行榜
    LeaderboardManager.addScore(time);
  }
  List<List<int>> generateCircularMaze(int size) {
    final int radius;
    radius = size ~/ 2;
// 初始化迷宮，所有格子默認為牆壁（1）
    List<List<int>> maze = List.generate(size, (_) => List.generate(size, (_) => 1));

    // 計算中心點
    int centerX = size ~/ 2;
    int centerY = size ~/ 2;

    // 確保起點是道路
    maze[centerY][centerX] = 2; // 標記起點

    // 定義方向（上下左右）
    final directions = [
      [0, 2],
      [0, -2],
      [2, 0],
      [-2, 0],
    ];

    Random random = Random();

    // 深度优先搜索生成迷宮
    void dfs(int x, int y) {
      directions.shuffle(random); // 隨機打亂方向
      for (var dir in directions) {
        int nx = x + dir[0];
        int ny = y + dir[1];

        // 檢查新位置是否在圓形內，且未被訪問
        if (isInCircle(nx, ny, centerX, centerY, radius) && maze[ny][nx] == 1) {
          // 連通牆壁
          maze[ny][nx] = 0;
          maze[y + dir[1] ~/ 2][x + dir[0] ~/ 2] = 0;

          // 遞歸生成
          dfs(nx, ny);
        }
      }
    }

    // 開始生成迷宮
    dfs(centerX, centerY);

    // 隨機選擇外圍的一個終點
    List<List<int>> outerPoints = [];
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (isOnCircleEdge(x, y, centerX, centerY, radius)) {
          outerPoints.add([x, y]);
        }
      }
    }

    var exitPoint = outerPoints[random.nextInt(outerPoints.length)];
    maze[exitPoint[1]][exitPoint[0]] = 3; // 標記終點

    return maze;
  }

  // 判斷點是否在圓形內
  bool isInCircle(int x, int y, int centerX, int centerY, int radius) {
    return pow(x - centerX, 2) + pow(y - centerY, 2) <= pow(radius, 2);
  }

  // 判斷點是否在圓形邊緣
  bool isOnCircleEdge(int x, int y, int centerX, int centerY, int radius) {
    double dist = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
    return dist >= radius - 1 && dist <= radius;
  }
}




class MazePainter extends CustomPainter {
  final List<List<int>> maze;
  final int playerX;
  final int playerY;
  final double cellSize;
  final double viewRadius; // 可見範圍，以格子數為半徑計算

  MazePainter({
    required this.maze,
    required this.playerX,
    required this.playerY,
    required this.cellSize,
    required this.viewRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint wallPaint = Paint()..color = Colors.black;
    Paint roadPaint = Paint()..color = Colors.white;
    Paint playerPaint = Paint()..color = Colors.green;
    Paint exitPaint = Paint()..color = Colors.red;
    Paint maskPaint = Paint()..color = Colors.black.withOpacity(0.7);

    // 畫布中心點
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 繪製迷宮格子
    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        double dx = (x - playerX).toDouble();
        double dy = (y - playerY).toDouble();
        double distance = sqrt(dx * dx + dy * dy);

        // 只繪製在圓形視野內的格子
        if (distance <= viewRadius) {
          Rect cellRect = Rect.fromLTWH(
            centerX + dx * cellSize - cellSize / 2,
            centerY + dy * cellSize - cellSize / 2,
            cellSize,
            cellSize,
          );

          if (maze[y][x] == 1) {
            canvas.drawRect(cellRect, wallPaint); // 繪製牆壁
          } else if (maze[y][x] == 0) {
            canvas.drawRect(cellRect, roadPaint); // 繪製道路
          } else if (maze[y][x] == 3) {
            canvas.drawRect(cellRect, exitPaint); // 繪製終點
          }
        }
      }
    }

    // 繪製玩家在畫布中心
    canvas.drawCircle(
      Offset(centerX, centerY),
      cellSize / 2,
      playerPaint,
    );

    // 遮罩圓形以外的部分
    canvas.drawCircle(
      Offset(centerX, centerY),
      viewRadius * cellSize,
      maskPaint..blendMode = BlendMode.dstOut,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
