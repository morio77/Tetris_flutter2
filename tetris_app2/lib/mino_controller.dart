import 'dart:async';

import 'package:flutter/material.dart';

import 'mino_models.dart';

import 'dart:math' as math;

const int lowerLimitOfFallSpeed = 100; // 落下速度の下限
final random = math.Random();

class MinoController extends ChangeNotifier{
  final int initialFallSpeed;
  MinoController(this.initialFallSpeed);

  Timer timer;
  int currentFallSpeed; // 現在の落下速度
  bool isGameOver = false; // ゲームオーバーになったかどうか。
  MinoRingBuffer minoRingBuffer = MinoRingBuffer(); // 7種1巡の法則が適用された、出現するミノをリングバッファとして保持

  /// 落下して位置が決まったすべてのミノ（フィックスしたミノ）
  List<List<MinoType>> fixedMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => MinoType.values[0]));
  // ↓こんな感じなのができる
  // [
  //   [0,0,0,0,0,0,0,0,0,0,], // 0 ではなく、本当はenumで表している
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  // ];


  @override
  void dispose() {
    super.dispose();

    if (timer != null) timer.cancel();
    timer = null;
  }

  /// ゲームスタート
  void startGame() {
    // 初期速度を今の速度に反映
    currentFallSpeed = initialFallSpeed;

    // タイマーONして、メインループへ
    onTimer();
  }



  /// タイマーON
  void onTimer() {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: currentFallSpeed), mainLoop);
  }



  /// =============
  /// メインのループ
  /// =============
  /// ①前処理（ミノを生成する）
  /// ②1マス落下のループ処理
  /// ③後処理（ミノをフィックスさせる）
  void mainLoop(Timer _timer) {

    if (isGameOver) {
      // 終わり
    }

    _preProcessing();

    _subRoutine();

    _postProcessing();

    notifyListeners();
  }



  /// 前処理
  void _preProcessing() {

    // 落下中のミノがなければ、落下中のミノを生成する（ポインタを1つ進める）
    minoRingBuffer.forwardPointer();

    // 衝突判定

  }

  /// 1段落とす
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
      // debugPrint("");
    }

  }

  /// 後処理
  void _postProcessing() {
    // カレントミノをフィックスさせる

    // 消せる行があったら、消す

    // 落下速度を速める（タイマーをリセットする）
    _changeTimerDurationPossible();
  }

  /// （フィックス後に）タイマーを速める
  void _changeTimerDurationPossible() {
    // 落下速度を 1ms 速める
    if (currentFallSpeed > lowerLimitOfFallSpeed){
      currentFallSpeed--;
    }

    // タイマーONして、メインループに戻る
    onTimer();
  }

  /// ミノが下端と衝突するか判定する
  bool _isCollideBottom() {
    return true;
  }
}