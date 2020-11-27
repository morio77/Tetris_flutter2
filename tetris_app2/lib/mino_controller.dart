import 'dart:async';

import 'package:flutter/material.dart';

import 'mino_state.dart';

import 'dart:math' as math;

const int lowerLimitOfFallSpeed = 100; // 落下速度の下限
final random = math.Random();

class MinoController extends ChangeNotifier{
  final int initialFallSpeed;
  MinoController(this.initialFallSpeed);

  Timer timer;
  int currentFallSpeed; // 現在の落下速度
  bool isGameOver = false; // ゲームオーバーになったかどうか。
  MinoRingBuffer minoRingBuffer; // 7種1巡の法則が適用された、出現するミノをリングバッファとして保持

  /// ゲームスタート
  void startGame() {
    // ミノリストを生成する

    // メインループへ
    mainLoop(timer);
  }


  /// =============
  /// メインのループ
  /// =============
  /// ①前処理（ミノを生成する）
  /// ②1マス落下のループ処理
  /// ③後処理（ミノをフィックスさせる）
  void mainLoop(Timer timer) {

    _changeTimerTimePossible();

    if (isGameOver) {
      // 終わり
    }

    _preProcessing();

    _subRoutine();

    _postProcessing();

    debugPrint(DateTime.now().toString());
  }



  /// 前処理
  void _preProcessing() {

    // ミノを生成する

    // 衝突判定

  }

  /// フィックスするまで1段落とし続ける
  Future<void> _subRoutine() async {
    bool isFixed = false;
    int deferralCount = 0; // 0.5秒の猶予を使える回数

    // 1段落下させられるなら、1段落下させる
    if (!_isCollideBottom()) {

    }
    // 1段落下させられないなら、0.5秒の猶予を設ける
    else {
      isFixed = true;
    }

    // 0.5秒の猶予（15回まで使える）
    if (isFixed && deferralCount < 15) {

      // ToDo:ここでタイマーの時間を0.5に変えてなんとかできないか

      if (!_isCollideBottom()) {
        isFixed = false;
        deferralCount++;
      }
    }

    // フィックスしたらフラグを立てる
    if (isFixed) {
      debugPrint("");
    }

  }

  /// 後処理
  void _postProcessing() {
    // カレントミノをフィックスさせる

  }

  ///
  void _changeTimerTimePossible() {
    // 落下速度を 1ms 速める
    if (currentFallSpeed > lowerLimitOfFallSpeed){
      currentFallSpeed--;
    }
    timer = Timer.periodic(Duration(milliseconds: initialFallSpeed), mainLoop);

  }

  /// ミノが下端と衝突するか判定する
  bool _isCollideBottom() {
    return true;
  }
}