import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicController with ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  /// 播放音樂
  Future<void> playMusic(String assetPath) async {
    try {
      await player.stop(); // 停止當前音樂，避免重疊
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("播放音樂時發生錯誤: $e");
    }
  }

  /// 暫停音樂
  Future<void> pauseMusic() async {
    try {
      await player.pause();
    } catch (e) {
      debugPrint("暫停音樂時發生錯誤: $e");
    }
  }

  /// 恢復播放
  Future<void> resumeMusic() async {
    try {
      await player.resume();
    } catch (e) {
      debugPrint("恢復音樂時發生錯誤: $e");
    }
  }

  /// 停止音樂
  Future<void> stopMusic() async {
    try {
      await player.stop();
    } catch (e) {
      debugPrint("停止音樂時發生錯誤: $e");
    }
  }

  /// 設置循環播放
  void enableLoop(String assetPath) {
    player.onPlayerComplete.listen((_) {
      playMusic(assetPath); // 音樂結束時自動重播
    });
  }
}
