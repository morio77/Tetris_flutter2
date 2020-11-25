import 'package:flutter/material.dart';

import 'mino_state.dart';

const int lowerLimitOfFallSpeed = 100; // 落下速度の下限

class MinoController extends ChangeNotifier{
  final int initialFallSpeed;
  MinoController(this.initialFallSpeed);

  int currentFallSpeed; // 現在の落下速度
  bool isGameOver = false; // ゲームオーバーになったかどうか。

  /// =============
  /// メインのループ
  /// =============
  /// ①前処理（ミノを生成する）
  /// ②1マス落下のループ処理
  /// ③0.5秒の猶予
  /// ④後処理（ミノをフィックスさせる）
  void mainLoop() {

    currentFallSpeed = initialFallSpeed;

    while(!isGameOver){
      _preProcessing();

      _subRoutine();

      _graceBeforeFixing();

      _PostProcessing();
    }

  }

  /// 前処理
  void _preProcessing() {
    // 落下速度を 1 速める
    if (currentFallSpeed > lowerLimitOfFallSpeed){
      currentFallSpeed--;
    }

  }

  void _subRoutine() {

  }

  void _graceBeforeFixing() {

  }

  void _PostProcessing() {

  }
}